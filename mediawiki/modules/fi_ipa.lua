local export = {}

local m_IPA = require("Module:IPA")
local m_hyph = require("Module:fi-hyphenation")
local lang = require("Module:languages").getByCode("fi")

local gsub = mw.ustring.gsub

local U = mw.ustring.char
local nonsyllabic = U(0x32F)	-- inverted breve below
local unreleased = U(0x31A)
local long = "ː"

local letters_phonemes = {
	["a"] = "ɑ",
	["ä"] = "æ",
	["ö"] = "ø",
	["å"] = "o",
	
	["g"] = "ɡ",
	["q"] = "k",
	["v"] = "ʋ",
	["š"] = "ʃ",
	["ž"] = "ʒ",
	
	["x"] = "ks",
	["zz"] = "ts",
	["ng"] = "ŋː",
	["nk"] = "ŋk",
	["nkk"] = "ŋkː",
	["qu"] = "kʋ",
	["*"] = "ˣ",
	["’"] = ".",
}

local lookahead = 3 -- how many unstressed syllables at most in a single unit, thus max consecutive unstressed syllables

local vowels = "ɑeiouyæø"
local vowel = "[" .. vowels .. "]"
local consonants = "kptɡgbdfʔsnmŋlrhʋʃʒrjçɦx"
local consonant = "[" .. consonants .. "]"
local diacritics = "̝̞̠̪"
local diacritic = "[" .. diacritics .. "]"

local spelled_consonants = "cšvwxzž"
local spelled_consonant = "[" .. consonants .. spelled_consonants .. "]"
local spelled_vowels = "aäö"
local spelled_vowel = "[" .. vowels .. spelled_vowels .. "]"

local tertiary = "ˌ" -- "tertiary stress", a weaker secondary stress (either rhythmic or in some compound words). is there a better way to represent this?
export.tertiary = tertiary

local stress_indicator = "[ ˈˌ" .. tertiary .. "/-]"
local plosives = "kptbdɡ"

local stress_p = "[ˈˌ" .. tertiary .. "]"
local stress_s = "[ˌ" .. tertiary .. "]"

local replacements_narrow = {
	["e"] = "e̞",
	["ø"] = "ø̞",
	["o"] = "o̞",
	["t"] = "t̪",
	["s"] = "s̠"
}

--	This adds letters_phonemes["e"] = "e", letters_phonemes["i"] = "i", etc.
for letter in mw.ustring.gmatch("eiouydhfjklmnprstu", ".") do
	letters_phonemes[letter] = letter
end

--[[	This regex finds the diphthongs in the IPA transcription,
		so that the nonsyllabic diacritic can be added.						]]
-- /_i/ diphthongs can appear in any syllable
local diphthongs_i = {
	"[ɑeouyæø]i"
}
-- /_U/ diphthongs can appear in the initial syllable or later open syllables (no consonantal coda)
local diphthongs_u = {
	"[ɑoei]u",
	"[eiæø]y",
}
-- rising diphthongs can only appear in the initial syllable (of a word, compound word part, etc.)
local diphthongs_rising = {
	"uo",
	"ie",
	"yø",
}

local post_fixes = {
	["t̪s̠"] = "ts̠",         -- t is alveolar in /ts/
	["nt̪"] = "n̪t̪",         -- n is dental in /nt/
	["ˈŋn"] = "ˈɡn",       -- initial <gn> is /gn/
						   -- ŋ is short before consonant (by default)
	["ŋ"..long.."("..consonant..")"] = "ŋ%1",
						   -- dissimilation of vowels by sandhi
	["("..vowel..diacritic.."*"..long.."?)("..stress_s..")%1"] = "%1%2(ʔ)%1"
}

local post_fixes_narrow = {
						   -- long j, v after i, u diphthong
	["(i"..nonsyllabic..")j("..vowel..")"] = "%1j("..long..")%2",
	["(u"..nonsyllabic..")ʋ("..vowel..")"] = "%1ʋ("..long..")%2",
						   -- cleanup
	["("..stress_s..")%."] = "%1",
						   -- sandhi: nm > mm, np > mp, nb > mb, nk > ŋk, ng > ŋg
	["nm"] = "m" .. long,
	["n([pb])"] = "m%1",
	["n("..stress_p.."%s*)([ɡk])"] = "ŋ%1%2",
	["n("..stress_p.."%s*)([mpb])"] = "m%1%2",
						   -- handle potentially long consonants over secondary stresses
	["("..stress_s..")("..consonant..diacritic.."*)%("..long.."%)"] = "(%2)%1%2",
	["("..consonant..diacritic.."*)%("..long.."%)("..stress_s..")"] = "%2%1("..long..")"
}

function export.is_light_syllable(syllable)
	return #syllable < 4 and mw.ustring.find(mw.ustring.lower(syllable), "^[" .. m_hyph.sep_symbols .. "]?" .. spelled_consonant .. "?" .. spelled_vowel .. "$", pos)
end

function export.has_later_heavy_syllable(hyph, start)
	local stop = math.min(start + lookahead, #hyph)
	for index = start, stop do
		if not export.is_light_syllable(hyph[index]) then
			return true
		end
	end
	return false	
end

-- applied *before* IPA conversion
local function add_secondary_stress(word)
	-- keep_sep_symbols = true
	local hyph = m_hyph.generate_hyphenation(word, true)
	local res = ""
	local last_index = #hyph
	
	-- find stressed syllables and add secondary stress before each syllable
	for index, syllable in ipairs(hyph) do
		local stressed = false
		local has_symbol = mw.ustring.find(syllable, "^[" .. m_hyph.sep_symbols .. "ˈˌ" .. tertiary .. "]")
		
		if has_symbol then
			-- check if symbol indicates stress
			stressed = mw.ustring.find(syllable, "^" .. stress_indicator)
			has_symbol = stressed
		end
			
		if not stressed then
			if index == 1 then
				stressed = true
			elseif not prev_stress and index < last_index then
				-- shift stress if current syllable light and a heavy syllable occurs later
				stressed = index == last_index - 1 or not export.is_light_syllable(syllable) or not export.has_later_heavy_syllable(hyph, index + 1)
			end
			
			if stressed then
				last_stressed = index
			end
		end
		
		-- check if next syllable already stressed
		-- if is, do not stress this syllable
		if stressed and index < last_index then
			stressed = stressed and not mw.ustring.find(hyph[index + 1], "^" .. stress_indicator)
		end

		if index > 1 and stressed and not has_symbol then
			res = res .. "-$"
		end
		res = res .. syllable

		prev_stress = stressed
	end

	local noninitial = {}
	local index = 1
	res = mw.ustring.gsub(res, "-([$]?)",
		function (dollar)
			index = index + 1
			noninitial[index] = #dollar > 0
			return #dollar > 0 and tertiary or "-"
		end)
	
	return res, noninitial
end

local function handle_diphthongs(IPA, strict_initial)
	-- Add nonsyllabic diacritic after last vowel of diphthong.
	for _, diphthong_regex in pairs(diphthongs_i) do
		IPA = mw.ustring.gsub(IPA, diphthong_regex, "%0" .. nonsyllabic)
	end

	local only_initial = stress_indicator .. "[^" .. vowels .. "]*"
	if strict_initial then
		only_initial = "^[^" .. vowels .. "]*"
	end

	for _, diphthong_regex in pairs(diphthongs_rising) do
		-- initial syllables
		IPA = mw.ustring.gsub(IPA, only_initial .. diphthong_regex, "%0" .. nonsyllabic)
	end

	for _, diphthong_regex in pairs(diphthongs_u) do
		-- initial syllables
		IPA = mw.ustring.gsub(IPA, only_initial .. diphthong_regex, "%0" .. nonsyllabic)

		-- open non-initial syllables
		IPA = mw.ustring.gsub(IPA, "(" .. diphthong_regex .. ")$(.+)", 
			function(diphthong, after)
				if mw.ustring.find(after, "^" .. consonant .. vowel) then
					-- consonant after diphthong
					-- must be followed by vowel so that it's part of the
					-- following syllable, else it's in this syllable
					-- and thus this syllabie is closed

					return diphthong .. nonsyllabic .. after
				elseif mw.ustring.find(after, "^" .. consonant) then
					-- consonant after diphthong
					-- must be in this syllable

					return diphthong .. after
				end
				-- no consonant after diphthong => open
				return diphthong .. nonsyllabic .. after
			end)
	end

	return IPA
end

local function IPA_word(term, is_narrow, has_initial)
	local rest = term
	local phonemes = {}
	
	while mw.ustring.len(rest) > 0 do
		-- Find the longest string of letters that matches a recognised sequence in the list
		local longestmatch = ""
		
		for letter, phoneme in pairs(letters_phonemes) do
			if mw.ustring.sub(rest, 1, mw.ustring.len(letter)) == letter and mw.ustring.len(letter) > mw.ustring.len(longestmatch) then
				longestmatch = letter
			end
		end
		
		-- Convert the string to IPA
		if mw.ustring.len(longestmatch) > 0 then
			table.insert(phonemes, letters_phonemes[longestmatch])
			rest = mw.ustring.sub(rest, mw.ustring.len(longestmatch) + 1)
		else
			table.insert(phonemes, mw.ustring.sub(rest, 1, 1))
			rest = mw.ustring.sub(rest, 2)
		end
	end
	
	local result = table.concat(phonemes)
	
	if is_narrow then
		-- articulation of h
		result = mw.ustring.gsub(result, "(.?)h(.?)",
			function (before, after)
				local h
				if after ~= "" then
					if before ~= "" and vowels:find(before) then
						if consonants:find(after) then
							-- vihma, yhtiö
							if before == "i" or before == "y" then
								h = "ç"
							-- mahti, kohme, tuhka
							elseif before == "ɑ" or before == "o" or before == "u" then
								h = "x"
							end
						-- maha
						elseif vowels:find(after) then
							h = "ɦ"
						end
					end
				end
				
				if h then
					return before .. h .. after
				end
			end)
		
		-- double letter replacement and diphthongs must be handled earlier here
		result = mw.ustring.gsub(result, "(%a)%1", "%1" .. long)
		if has_initial then
			result = handle_diphthongs(result, true)
		end
	
		for letter, phoneme in pairs(replacements_narrow) do
			result = mw.ustring.gsub(result, letter, phoneme)
		end
	end
	
	return result
end

function export.IPA_wordparts(term, is_narrow)
	term = mw.ustring.lower(term)
	local notinitial = {} -- true if the component is not an initial component
	local hyphenstress = "ˌ" -- secondary by default

	if mw.ustring.find(term, "%/") then
		hyphenstress = tertiary -- tertiary if we have slashes
	end
	
	if is_narrow then
		term, notinitial = add_secondary_stress(term)
	end
	
	term = mw.ustring.gsub(term, "^%-+", "")
	term = mw.ustring.gsub(term, "%-+$", "")
	
	-- make sure we keep slashes to figure out if secondary or tertiary
	term = mw.ustring.gsub(term, "%/", "-%1")
	local wordparts = mw.text.split(term, "-", true)

	for key, val in ipairs(wordparts) do
		local stress = key > 1 and hyphenstress or "ˈ"
		local part = val

		if mw.ustring.find(part, "^%/") then
			stress = "ˌ" -- always secondary
			part = part:sub(2)
		end

		wordparts[key] = stress .. IPA_word(part, is_narrow, not notinitial[key])
	end
	
	IPA = table.concat(wordparts, "")
	
	if is_narrow then
		-- handle * in narrow transcription
		IPA = mw.ustring.gsub(IPA, "ˣ(%s*)("..stress_p.."?)((.?)" .. diacritic .. "*)",
			function (space, stress, after, potential_consonant)
				if potential_consonant == "" then
					return space .. stress .. "(ʔ)" .. after
				elseif consonants:find(potential_consonant) then
					if #space > 0 or #stress > 0 then
						local amark = ""
						if plosives:find(mw.ustring.sub(after, 1, 1)) then
							amark = unreleased
						end
						return after .. amark .. space .. stress .. after
					else
						return space .. after .. long
					end
				else
					return space .. stress .. "ʔ" .. after
				end
			end)		
	else
		--	Replace double letters (vowels or consonants) with single letter plus length sign.
		IPA = gsub(IPA, "(%a)%1", "%1" .. long)
		IPA = handle_diphthongs(IPA, false)
	end
	
	for letter, phoneme in pairs(post_fixes) do
		IPA = mw.ustring.gsub(IPA, letter, phoneme)
	end
	
	if is_narrow then
		for letter, phoneme in pairs(post_fixes_narrow) do
			IPA = mw.ustring.gsub(IPA, letter, phoneme)
		end
	end
	
	return IPA
end

function export.convertToIPA(term)
	-- if type(term) == "table" then
	-- 	term = term:getParent().args[1]
	-- end
	
	-- local title = mw.title.getCurrentTitle().text
	
	-- if not term then
	-- 	term = title
	-- elseif term == "*" then
	-- 	term = title .. "*"
	-- end
	
	local no_count = mw.ustring.match(term, " ")
	
	IPA_narrow = export.IPA_wordparts(term, true)
    IPA = export.IPA_wordparts(term, false)
    return IPA;
	--return m_IPA.format_IPA_full(lang, {{pron = "/" .. IPA .. "/"}, {pron = "[" .. IPA_narrow .. "]"}}, nil, nil, nil, no_count)
end

return export