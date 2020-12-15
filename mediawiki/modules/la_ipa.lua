local export = {}

local m_a = require("Module:accent_qualifier")
local m_IPA = require("Module:IPA")
local ut = require("Module:utils")
local lang = require("Module:languages").getByCode("la")

local u = mw.ustring.char
local rfind = mw.ustring.find
local rsubn = mw.ustring.gsub
local rmatch = mw.ustring.match
local rsplit = mw.text.split
local ulower = mw.ustring.lower
local usub = mw.ustring.sub
local ulen = mw.ustring.len

local BREVE = u(0x0306) -- breve =  ̆
local TILDE = u(0x0303) -- ̃
local HALF_LONG = "ˑ"
local LONG = "ː"

local letters_ipa = {
	["a"] = "a",["e"] = "e",["i"] = "i",["o"] = "o",["u"] = "u",["y"] = "y",
	["ā"] = "aː",["ē"] = "eː",["ī"] = "iː",["ō"] = "oː",["ū"] = "uː",["ȳ"] = "yː",
	["ae"] = "ae̯",["oe"] = "oe̯",["ei"] = "ei̯",["au"] = "au̯",["eu"] = "eu̯",
	["b"] = "b",["d"] = "d",["f"] = "f",
	["c"] = "k",["g"] = "ɡ",["v"] = "w",["x"] = "ks",
	["ph"] = "pʰ",["th"] = "tʰ",["ch"] = "kʰ",["gh"] = "ɡʰ",["rh"] = "r",["qv"] = "kʷ",["gv"] = "ɡʷ",
	["'"] = "ˈ",["ˈ"] = "ˈ",
}

local letters_ipa_eccl = {
	["a"] = "a",["e"] = "e",["i"] = "i",["o"] = "o",["u"] = "u",["y"] = "i",
	["ā"] = "aː",["ē"] = "eː",["ī"] = "iː",["ō"] = "oː",["ū"] = "uː",["ȳ"] = "iː",
	["ae"] = "eː",["oe"] = "eː",["ei"] = "ei̯",["au"] = "au̯",["eu"] = "eu̯",
	["b"] = "b",["d"] = "d",["f"] = "f",
	["c"] = "k",["g"] = "ɡ",["v"] = "v",["x"] = "ks",
	["ph"] = "f",["th"] = "tʰ",["ch"] = "kʰ",["gh"] = "ɡʰ",["rh"] = "r",["qv"] = "kw",["gv"] = "ɡw",
	["h"] = "",
	["'"] = "ˈ",["ˈ"] = "ˈ",
}

local letters_ipa_vul = {
	["a"] = "a",["e"] = "ɛ",["i"] = "i",["o"] = "ɔ",["u"] = "u",["y"] = "e",
	["ā"] = "aː",["ē"] = "eː",["ī"] = "iː",["ō"] = "oː",["ū"] = "uː",["ȳ"] = "eː",
	["ae"] = "e",["oe"] = "e",["ei"] = "ei̯",["au"] = "au̯",["eu"] = "eu̯",
	["b"] = "β",["d"] = "d",["f"] = "f",
	["c"] = "k",["g"] = "ɡ",["v"] = "β",["x"] = "s",
	["ph"] = "f",["th"] = "tʰ",["ch"] = "kʰ",["gh"] = "g",["rh"] = "r",["qv"] = "kʷ",["gv"] = "ɡʷ",
	["h"] = "",
	["'"] = "ˈ",["ˈ"] = "ˈ",
}

local lax_vowel = {
	["e"] = "ɛ",
	["i"] = "ɪ",
	["o"] = "ɔ",
	["u"] = "ʊ",
	["y"] = "ʏ",
}

local tense_vowel = {
	["ɛ"] = "e",
	["ɪ"] = "i",
	["ɔ"] = "o",
	["ʊ"] = "u",
	["ʏ"] = "y",
}

local classical_vowel_letters = "aeɛiɪoɔuʊyʏ"
local classical_vowel = "[" .. classical_vowel_letters .. "]"

local phonetic_rules = {
	-- Velar nasal assimilation
	{"ɡ([.ˈ]?)n", "ŋ%1n"},
	{"n([.ˈ]?)([kɡ])", "ŋ%1%2"},
	{"m([.ˈ]?)([kɡ])", "ŋ%1%2"},
	
	-- Fronted labialization before front vowels
	{"ʷ%f[eɛiɪyʏ]", "ᶣ"},
	
	-- No additional labialization before high back vowels
	{"ʷ%f[uʊ]", ""},
	
	-- Tensing of vowels before another vowel
	{
		"([ɛɪʏ])([.ˈ]?)%f[aeɛiɪoɔuʊyʏ]",
		function (vowel, following)
			return (tense_vowel[vowel] or vowel) .. following
		end,
	},
	
	-- Nasal vowels
	{
		"(" .. classical_vowel .. ")m$",
		function (vowel)
			return (lax_vowel[vowel] or vowel) .. TILDE .. HALF_LONG
		end,
	},
	{
		"(" .. classical_vowel .. ")[nm]([.ˈ]?[sf])",
		function (vowel, following)
			return (tense_vowel[vowel] or vowel) .. TILDE .. LONG .. following
		end,
	},
	
	-- Allophones of L in line with Sen's 2015 phonological study and Pliny's exīlis-medius-pinguis distinction
	--- these two are positionally specified for two maximally different tongue-shapes
	{"l", "ɫ̪"}, -- pinguis, [+high, +back] and dental
	{"ɫ̪([.ˈ]?)ɫ̪", "l̠%1l̠"}, -- exīlis, [+high, -back] and ambiguously postalveolar. the strict [-back] might have further lead to tongue back lowering and retroflexion
	--- these three are basically underspecified and coloured progressively by surrounding vowels. diacritics here optional
	{"ɫ̪([aoɔuʊ])", "lˠ%1"}, -- medius plēnior
	{"ɫ̪([.ˈ]?[eɛ])", "l%1"}, -- medius vērus
	{"ɫ̪([.ˈ]?[iɪyʏ])", "lʲ%1"}, -- medius exīlior
	
	-- Tapped R intervocalically and in complex onset
	{"([aeɛiɪoɔuʊyʏ][ː.ˈ]*)r(%f[aeɛiɪoɔuʊyʏ])", "%1ɾ%2"},
	{"([fbdgptkʰ])r", "%1ɾ"},
	
	-- retracted S
	{"s", "s̠"},
	
    -- Dental articulations
	{"t", "t̪"},
	{"d", "d̪"},
	{"n([.ˈ]?)([td])", "n̪%1%2"}, --it's not as clear as for the stops
}

local phonetic_rules_eccl = {
	{"n([.ˈ]?)([kɡ])", "ŋ%1%2"}, --velar nasal assimilation
	{"m([.ˈ]?)([kɡ])", "ŋ%1%2"},
	{"([aɛeiɔou][ː.ˈ]*)s([.ˈ]*)%f[aɛeiɔou]", "%1z%2"}, --voicing of s between vowels

    --According to one rule, /e/ and /o/ are consistently mid-open in quality
	{"e", "ɛ"},
	{"o", "ɔ"},
    -- Dental articulations
	{"n([.ˈ]?)([td])([^͡])", "n̪%1%2%3"}, --assimilation of n to dentality. 
    {"l([.ˈ]?)([td])([^͡])", "l̪%1%2%3"},
    --Note that the quality of n might not be dental otherwise--it may be alveolar in most contexts in Italian, according to Wikipedia.
	{"t([^͡])", "t̪%1"},       --t is dental, except not necessarily as the first element of an affricate
	{"d([^͡])", "d̪%1"},       --d is dental, except not necessarily as the first element of an affricate
    {"t̪([.ˈ]?)t͡ʃ", "t%1t͡ʃ"},
    {"d̪([.ˈ]?)d͡ʒ", "d%1d͡ʒ"},
    {"d̪([.ˈ]?)d͡z", "d%1d͡z"},

    --end of words
	{"lt$", "l̪t̪"},
	{"nt$", "n̪t̪"},
	{"t$", "t̪"},
	{"d$", "d̪"},

    --Partial assimilation of n and l before palatal affricates, as in Italian
    {"n([.ˈ]?)t͡ʃ", "n̠ʲ%1t͡ʃ"},
    {"n([.ˈ]?)d͡ʒ", "n̠ʲ%1d͡ʒ"},
    {"n([.ˈ]?)ʃ", "n̠ʲ%1ʃ"},
    {"l([.ˈ]?)t͡ʃ", "l̠ʲ%1t͡ʃ"},
    {"l([.ˈ]?)d͡ʒ", "l̠ʲ%1d͡ʒ"},
    {"l([.ˈ]?)ʃ", "l̠ʲ%1ʃ"},

}

local lenition = {
	["ɡ"] = "ɣ", ["g"] = "ɣ", ["d"] = "ð", ["k"] = "ɡ", ["t"] = "d", ["p"] = "b",
}

local phonetic_rules_vul = {
	{"β([.ˈ])β","b%1b"},
	{"([bdfghklmnprstvwzɣðβʰʷ]ː?)[ɛei]([.ˈ][aɔo])","%1ʲ%2"},
	-- FIXME: Does the restriction to short u make sense?
	{"([bdfghklmnprstvwzɣðβʰʷ]ː?)[ɛei]([.ˈ]u[^ː])","%1ʲu%2"},
	{"k([ɛei])","k%1"},
	{"([bdfghklmnprstvwzɣðβʰʷ]ː?)u([.ˈ][aɛeiɔo])","%1ʷ%2"},
	{"i([^ː])", "e%1"},
	{"u([^ː])", "o%1"},
	{"βʲ","βj"},
	{"^(ˈ?)β","%1b"},
	{"([aɛeiɔouː][.ˈ])([ɡdktp])%f[aɛeiɔou]", function (before, consonant)
		return before .. lenition[consonant]
	end},
	{"a[nm]$", "ã"},
	{"[eɛ][nm]$", "ẽ"},
	{"i[nm]$", "ĩ"},
	{"[oɔ][nm]$", "õ"},
	{"u[nm]$", "ũ"},
	{"ː",""},
}

local lengthen_vowel = {
	["a"] = "aː", ["aː"] = "aː",
	["ɛ"] = "ɛː", ["ɛː"] = "ɛː",
	["e"] = "eː", ["eː"] = "eː",
	["i"] = "iː", ["iː"] = "iː",
	["ɔ"] = "ɔː", ["ɔː"] = "ɔː",
	["o"] = "oː", ["oː"] = "oː",
	["u"] = "uː", ["uː"] = "uː",
}

local vowels = {
	"a", "ɛ", "e", "ɪ", "i", "ɔ", "o", "ʊ", "u", "y",
	"aː", "ɛː", "eː", "iː", "ɔː", "oː", "uː", "yː",
	"ae̯", "oe̯", "ei̯", "au̯", "eu̯",
}


local onsets = {
	"b", "p", "pʰ", "d", "t", "tʰ", "β",
	"ɡ", "gʰ", "k", "kʰ", "kʷ", "ɡʷ", "kw", "ɡw", "t͡s", "t͡ʃ", "d͡ʒ", "ʃ",
	"f", "s", "h", "z", "d͡z",
	"l", "m", "n", "ɲ", "r", "j", "v", "w",
	
	"bl", "pl", "pʰl", "br", "pr", "pʰr",
	"dr", "tr", "tʰr",
	"ɡl", "kl", "kʰl", "ɡr", "kr", "kʰr",
	"fl", "fr",
	
	"sp", "st", "sk", "skʷ", "sw",
	"spr", "str", "skr",
	"spl", "skl",
}

local codas = {
	"b", "p", "pʰ", "d", "t", "tʰ", "ɡ", "k", "kʰ", "β",
	"f", "s", "z",
	"l", "m", "n", "ɲ", "r", "j", "ʃ",
	
	"sp", "st", "sk",
	"spʰ", "stʰ", "skʰ",
	
	"lp", "lt", "lk",
	"lb", "ld", "lɡ",
	"lpʰ", "ltʰ", "lkʰ",
	"lf",
	
	"rp", "rt", "rk",
	"rb", "rd", "rɡ",
	"rpʰ", "rtʰ", "rkʰ",
	"rf",
	
	"mp", "nt", "nk",
	"mb", "nd", "nɡ",
	"mpʰ", "ntʰ", "nkʰ",
	
	"lm", "rl", "rm", "rn",
	
	"ps", "ts", "ks", "ls", "ns", "rs",
	"lks", "nks", "rks", 
    "rps", "mps",
	"lms", "rls", "rms", "rns",
}

-- Prefixes that end in a consonant; can be patterns. Occurrences of such
-- prefixes + i + vowel cause the i to convert to j (to suppress this, add a
-- dot, i.e. syllable boundary, after the i).
local cons_ending_prefixes = {
	"a[bd]", "circum", "con", "dis", "ex", "in", "inter", "ob", "per",
	"sub", "subter", "super", "tr[aā]ns"
}

local remove_macrons = {
	["ā"] = "a",
	["ē"] = "e",
	["ī"] = "i",
	["ō"] = "o",
	["ū"] = "u",
	["ȳ"] = "y",
}

local macrons_to_breves = {
	["ā"] = "ă",
	["ē"] = "ĕ",
	["ī"] = "ĭ",
	["ō"] = "ŏ",
	["ū"] = "ŭ",
	-- Unicode doesn't have breve-y
	["ȳ"] = "y" .. BREVE,
}

local remove_breves = {
	["ă"] = "a",
	["ĕ"] = "e",
	["ĭ"] = "i",
	["ŏ"] = "o",
	["ŭ"] = "u",
	-- Unicode doesn't have breve-y
}

local remove_ligatures = {
	["æ"] = "ae",
	["œ"] = "oe",
}

for i, val in ipairs(vowels) do
	vowels[val] = true
end

for i, val in ipairs(onsets) do
	onsets[val] = true
end

for i, val in ipairs(codas) do
	codas[val] = true
end

-- NOTE: Everything is lowercased very early on, so we don't have to worry
-- about capitalized letters.
local short_vowels_string = "aeiouyăĕĭŏŭäëïöüÿ" -- no breve-y in Unicode
local long_vowels_string = "āēīōūȳ"
local vowels_string = short_vowels_string .. long_vowels_string
local vowels_c = "[" .. vowels_string .. "]"
local non_vowels_c = "[^" .. vowels_string .. "]"

-- version of rsubn() that discards all but the first return value
local function rsub(term, foo, bar)
	local retval = rsubn(term, foo, bar)
	return retval
end

-- version of rsubn() that returns a 2nd argument boolean indicating whether
-- a substitution was made.
local function rsubb(term, foo, bar)
	local retval, nsubs = rsubn(term, foo, bar)
	return retval, nsubs > 0
end

local function letters_to_ipa(word,phonetic,eccl,vul)
	local phonemes = {}
	
	local dictionary = eccl and letters_ipa_eccl or (vul and letters_ipa_vul or letters_ipa)
	
	while ulen(word) > 0 do
		local longestmatch = ""
		
		for letter, ipa in pairs(dictionary) do
			if ulen(letter) > ulen(longestmatch) and usub(word, 1, ulen(letter)) == letter then
				longestmatch = letter
			end
		end
		
		if ulen(longestmatch) > 0 then
			if dictionary[longestmatch] == "ks" then
				table.insert(phonemes, "k")
				table.insert(phonemes, "s")
			else
				table.insert(phonemes, dictionary[longestmatch])
			end
			word = usub(word, ulen(longestmatch) + 1)
		else
			table.insert(phonemes, usub(word, 1, 1))
			word = usub(word, 2)
		end
	end
	
	if eccl then for i=1,#phonemes do
		local prev, cur, next = phonemes[i-1], phonemes[i], phonemes[i+1]
		if next and (cur == "k" or cur == "ɡ") and rfind(next, "^[eɛi]ː?$") then
			if cur == "k" then
				if prev == "s" and ((not phonemes[i-2]) or phonemes[i-2] ~= "k") then
					prev = "ʃ"
					cur = "ʃ"
				else
					cur = "t͡ʃ"
					if prev == "k" then prev = "t" end
				end
			else
                cur = "d͡ʒ"
                if prev == "ɡ" then prev = "d" end
			end
		end
		if cur == "t" and next == "i" and not (prev == "s" or prev == "t")
				and vowels[phonemes[i+2]] then
			cur = "t͡s"
		end
		if cur == "z" then
            if next == "z" then
            	cur = "d"
            	next = "d͡z" 
            else
            	cur = "d͡z"
            end
		end
		if cur == "kʰ" then cur = "k" end
		if cur == "tʰ" then cur = "t" end
		if cur == "ɡ" and next == "n" then
			cur = "ɲ"
			next = "ɲ"
		end
		phonemes[i-1], phonemes[i], phonemes[i+1] = prev, cur, next
	end end
	
	return phonemes
end


local function get_onset(syll)
	local consonants = {}
	
	for i = 1, #syll do
		if vowels[syll[i]] then
			break
		end
		if syll[i] ~= "ˈ" then
			table.insert(consonants, syll[i])
		end
	end
	
	return table.concat(consonants)
end


local function get_coda(syll)
	local consonants = {}
	
	for i = #syll, 1, -1 do
		if vowels[syll[i]] then
			break
		end
		
		table.insert(consonants, 1, syll[i])
	end
	
	return table.concat(consonants)
end


local function get_vowel(syll)
	for i = 1,#syll do
		if vowels[syll[i]] then return syll[i] end
	end
end


-- Split the word into syllables of CV shape
local function split_syllables(remainder)
	local syllables = {}
	local syll = {}
	
	for _, phoneme in ipairs(remainder) do
		if phoneme == "." then
			if #syll > 0 then
				table.insert(syllables, syll)
				syll = {}
			end
			-- Insert a special syllable consisting only of a period.
			-- We remove it later but it forces no movement of consonants across
			-- the period.
			table.insert(syllables, {"."})
		elseif phoneme == "ˈ" then
			if #syll > 0 then
				table.insert(syllables,syll)
			end
			syll = {"ˈ"}
		elseif vowels[phoneme] then
			table.insert(syll, phoneme)
			table.insert(syllables, syll)
			syll = {}
		else
			table.insert(syll, phoneme)
		end
	end
	
	-- If there are phonemes left, then the word ends in a consonant.
	-- Add another syllable for them, which will get joined the preceding
	-- syllable down below.
	if #syll > 0 then
		table.insert(syllables, syll)
	end
	
	-- Split consonant clusters between syllables
	for i, current in ipairs(syllables) do
		if #current == 1 and current[1] == "." then
			-- If the current syllable is just a period (explicit syllable
			-- break), remove it. The loop will then skip the next syllable,
			-- which will prevent movement of consonants across the syllable
			-- break (since movement of consonants happens from the current
			-- syllable to the previous one).
			table.remove(syllables, i)
		elseif i > 1 then
			local previous = syllables[i-1]
			local onset = get_onset(current)
			-- Shift over consonants until the syllable onset is valid
			while not (onset == "" or onsets[onset]) do
				table.insert(previous, table.remove(current, 1))
				onset = get_onset(current)
			end
			
			-- If the preceding syllable still ends with a vowel,
			-- and the current one begins with s + another consonant, then shift it over.
			if get_coda(previous) == "" and (current[1] == "s" and not vowels[current[2]]) then
				table.insert(previous, table.remove(current, 1))
			end
			
			-- Check if there is no vowel at all in this syllable. That
			-- generally happens either (1) with an explicit syllable division
			-- specified, like 'cap.ra', which will get divided into the syllables
			-- [ca], [p], [.], [ra]; or (2) at the end of a word that ends with
			-- one or more consonants. We move the consonants onto the preceding
			-- syllable, then remove the resulting empty syllable. If the
			-- new current syllable is [.], remove it, too. The loop will then
			-- skip the next syllable, which will prevent movement of consonants
			-- across the syllable break (since movement of consonants happens
			-- from the current syllable to the previous one).
			if not get_vowel(current) then
				for j=1,#current do
					table.insert(previous, table.remove(current, 1))
				end
				table.remove(syllables, i)
				if syllables[i] and #syllables[i] == 1 and syllables[i][1] == "." then
					table.remove(syllables, i)
				end
			end
		end
	end
	
	for i, syll in ipairs(syllables) do
		local onset = get_onset(syll)
		local coda = get_coda(syll)
		
		if not (onset == "" or onsets[onset]) then
			require("Module:debug").track("la-pronunc/bad onset")
			--error("onset error:[" .. onset .. "]")
		end
		
		if not (coda == "" or codas[coda]) then
			require("Module:debug").track("la-pronunc/bad coda")
			--error("coda error:[" .. coda .. "]")
		end
	end
	
	return syllables
end

local function phoneme_is_short_vowel(phoneme)
	return rfind(phoneme, "^[aɛeiɔouy]$")
end

local function detect_accent(syllables, is_prefix, is_suffix)
	-- Manual override
	for i=1,#syllables do
		for j=1,#syllables[i] do
			if syllables[i][j] == "ˈ" then
				table.remove(syllables[i],j)
				return i
			end
		end
	end
	-- Prefixes have no accent.
	if is_prefix then
		return -1
	end
	-- Suffixes have an accent only if the stress would be on the suffix when the
	-- suffix is part of a word. Don't get tripped up by the first syllable being
	-- nonsyllabic (e.g. in -rnus).
	if is_suffix then
		local syllables_with_vowel = #syllables - (get_vowel(syllables[1]) and 0 or 1)
		if syllables_with_vowel < 2 then
			return -1
		end
		if syllables_with_vowel == 2 then
			local penult = syllables[#syllables - 1]
			if phoneme_is_short_vowel(penult[#penult]) then
				return -1
			end
		end
	end
	-- Detect accent placement
	if #syllables > 2 then
		-- Does the penultimate syllable end in a single vowel?
		local penult = syllables[#syllables - 1]
		
		if phoneme_is_short_vowel(penult[#penult]) then
			return #syllables - 2
		else
			return #syllables - 1
		end
	elseif #syllables == 2 then
		return #syllables - 1
	end
end


local function convert_word(word, phonetic, eccl, vul)
	-- Normalize i/j/u/v; do this before removing breves, so we keep the
	-- ŭ in langŭī (perfect of languēscō) as a vowel.
	word = rsub(word, "w", "v")
	word = rsub(word, "(" .. vowels_c .. ")v(" .. non_vowels_c .. ")", "%1u%2")
	word = rsub(word, "qu", "qv")
	word = rsub(word, "ngu(" .. vowels_c .. ")", "ngv%1")
	
	word = rsub(word, "^i(" .. vowels_c .. ")", "j%1")
	word = rsub(word, "^u(" .. vowels_c .. ")", "v%1")
	-- Per the August 31 2019 recommendation by [[User:Brutal Russian]] in
	-- [[Module talk:la-pronunc]], we convert i/j between vowels to jj if the
	-- preceding vowel is short but to single j if the preceding vowel is long.
	word = rsub(
		word,
		"(" .. vowels_c .. ")([iju])()",
		function (vowel, potential_consonant, pos)
			if vowels_string:find(usub(word, pos, pos)) then
				if potential_consonant == "u" then
					return vowel .. "v"
				else
					if long_vowels_string:find(vowel) then
						return vowel .. "j"
					else
						return vowel .. "jj"
					end
				end
			end
		end)

    --Convert v to u syllable-finally
	word = rsub(word, "v%.", "u.")
	word = rsub(word, "v$", "u")

    -- poetic meter shows that a consonant before "h" was syllabified as an onset, not as a coda. 
    -- Based on outcome of talk page discussion, this will be indicated by the omission of /h/ [h] in this context.
    word = rsub(word, "([dbnx])h", "%1")

	-- Convert i to j before vowel and after any prefix that ends in a consonant,
	-- per the August 23 2019 discussion in [[Module talk:la-pronunc]].
	for _, pref in ipairs(cons_ending_prefixes) do
		word = rsub(word, "^(" .. pref .. ")i(" .. vowels_c .. ")", "%1j%2")
	end

    -- In Italian, an intervocalic semivowel/glide (as in It. noia) is not geminated; instead, the preceding vowel is long when stressed
	if eccl then
        word = rsub(word, "(" .. vowels_c .. ")j([.ˈ]?)j(" .. vowels_c .. ")", "%1%2j%3")  -- replace j.j or jˈj with .j or ˈj between any vowels
    end

	-- Convert z to zz between vowels so that the syllable weight and stress assignment will be correct.
	word = rsub(word, "(" .. vowels_c .. ")z(" .. vowels_c .. ")", "%1zz%2")

	-- Now remove breves.
	word = rsub(word, "([ăĕĭŏŭ])", remove_breves)
	-- BREVE sits uncombined in y+breve and vowel-macron + breve
	word = rsub(word, BREVE, "")
	
	-- Normalize aë, oë; do this after removing breves but before any
	-- other normalizations involving e.
	word = rsub(word, "([ao])ë", "%1.e")

	-- Eu and ei diphthongs
	word = rsub(word, "e(u[ms])$", "e.%1")
	word = rsub(word, "ei", "e.i")
	word = rsub(word, "_", "")
	
	-- Vowel length before nasal + fricative is allophonic
	word = rsub(word, "([āēīōūȳ])([mn][fs])",
		function(vowel, nasalfric)
			return remove_macrons[vowel] .. nasalfric
		end
	)
	
	-- Apply some basic phoneme-level assimilations
	word = rsub(word, "xs?", "x")
	word = rsub(word, "b([cfpqst])", "p%1")
	word = rsub(word, "d([cfpqst])", "t%1")
	word = rsub(word, "g([cfpqst])", "k%1")
	word = rsub(word, "n([bp])", "m%1")

	-- Per May 10 2019 discussion in [[Module talk:la-pronunc]], we syllabify
	-- prefixes ab-, ad-, ob-, sub- separately from following l or r.
	word = rsub(word, "^a([bd])([lr])", "a%1.%2")	
	word = rsub(word, "^ob([lr])", "ob.%1")	
	word = rsub(word, "^sub([lr])", "sub.%1")	

	-- Remove hyphens indicating prefixes or suffixes; do this after the above,
	-- some of which are sensitive to beginning or end of word and shouldn't
	-- apply to end of prefix or beginning of suffix.
	local is_prefix, is_suffix
	word, is_prefix = rsubb(word, "%-$", "")
	word, is_suffix = rsubb(word, "^%-", "")

	-- Convert word to IPA
	local phonemes = letters_to_ipa(word,phonetic,eccl,vul)
	
	-- Split into syllables
	local syllables = split_syllables(phonemes)
	
	-- Add accent
	local accent = detect_accent(syllables, is_prefix, is_suffix)
	
	for i, syll in ipairs(syllables) do
		for j, phoneme in ipairs(syll) do
			if eccl then
				syll[j] = rsub(syll[j], "ː", "")
			elseif phonetic and not vul then
				syll[j] = lax_vowel[syll[j]] or syll[j]
			end
		end
	end
	
	for i, syll in ipairs(syllables) do
		if eccl and i == accent and phonetic and vowels[syll[#syll]] then
			syll[#syll] = lengthen_vowel[syll[#syll]] or syll[#syll]
		end
		
		for j=1, #syll-1 do
			if syll[j]==syll[j+1] then
				syll[j+1] = ""
			end
		end
	end
	
	for i, syll in ipairs(syllables) do
		syll = table.concat(syll)
		if vul and i ~= accent then
			syll = rsub(syll, "ɔ", "o")
			syll = rsub(syll, "ɛ", "e")
		end
		syllables[i] = (i == accent and "ˈ" or "") .. syll
	end
	
	word = (rsub(table.concat(syllables, "."), "%.ˈ", "ˈ"))
	
	if phonetic then
		local rules = eccl and phonetic_rules_eccl or (vul and phonetic_rules_vul or phonetic_rules)
		for i, rule in ipairs(rules) do
			word = rsub(word, rule[1], rule[2])
		end
	end

	if eccl then
        word = rsub(word, "([^aeɛioɔu])ʃ([.ˈ]?)ʃ", "%1%2ʃ")     -- replace ʃ.ʃ or ʃˈʃ with .ʃ or ˈʃ after any consonant
	end
	
	return word
end

function initial_canonicalize_text(text)
	-- Call ulower() even though it's also called in phoneticize,
	-- in case convert_words() is called externally.
	text = ulower(text)
	text = rsub(text, '[,?!:;()"]', '')
	text = rsub(text, '[æœ]', remove_ligatures)
	return text
end

function export.convert_words(text, phonetic, eccl, vul)
	text = initial_canonicalize_text(text)
	
	local disallowed = rsub(text, '[a-z%-āēīōūȳăĕĭŏŭë,.?!:;()\'"_ ' .. BREVE .. ']', '')
	if ulen(disallowed) > 0 then
		if ulen(disallowed) == 1 then
			error('The character "' .. disallowed .. '" is not allowed.')
		else
			error('The characters "' .. disallowed .. '" are not allowed.')
		end	
	end
	
	local result = {}
	
	for word in mw.text.gsplit(text, " ") do
		table.insert(result, convert_word(word, phonetic, eccl, vul))
	end
	
	return table.concat(result, " ")
end

-- Phoneticize Latin TEXT. Return a list of one or more phoneticizations,
-- each of which is a two-element list {PHONEMIC, PHONETIC}. If ECCL, use
-- Ecclesiastical pronunciation. If VUL, use Vulgar Latin pronunciation.
-- Otherwise, use Classical pronunciation.
function export.phoneticize(text, eccl, vul)
	local function do_phoneticize(text, eccl, vul)
		return {
			export.convert_words(text, false, eccl, vul),
			export.convert_words(text, true, eccl, vul),
		}
	end

	text = ulower(text)
	-- If we have a macron-breve sequence, generate two pronunciations, one for
	-- the long vowel and one for the short.
	if rfind(text, "[āēīōūȳ]" .. BREVE) then
		local longvar = rsub(text, "([āēīōūȳ])" .. BREVE, "%1")
		local shortvar = rsub(text, "([āēīōūȳ])" .. BREVE, macrons_to_breves)
		local longipa = do_phoneticize(longvar, eccl, vul)
		local shortipa = do_phoneticize(shortvar, eccl, vul)
		-- Make sure long and short variants are actually different (they won't
		-- be in Ecclesiastical pronunciation).
		if not ut.equals(longipa, shortipa) then
			return {longipa, shortipa}
		else
			return {longipa}
		end
	elseif  rfind(text, ";") then
        local tautosyllabicvar = rsub(text, ";", "")
        local heterosyllabicvar = rsub(text, ";", ".")
		local tautosyllabicipa = do_phoneticize(tautosyllabicvar, eccl, vul)
		local heterosyllabicipa = do_phoneticize(heterosyllabicvar, eccl, vul)
		if not ut.equals(tautosyllabicipa, heterosyllabicipa) then
			return {tautosyllabicipa, heterosyllabicipa}
		else
			return {tautosyllabicipa}
		end
	else
		return {do_phoneticize(text, eccl, vul)}
	end
end

local function make_row(phoneticizations, dials)
	local full_pronuns = {}
	for _, phoneticization in ipairs(phoneticizations) do
		local phonemic = phoneticization[1]
		local phonetic = phoneticization[2]
		local IPA_args = {{pron = '/' .. phonemic .. '/'}}
		if phonemic ~= phonetic then
			table.insert(IPA_args, {pron = '[' .. phonetic .. ']'})
		end
		table.insert(full_pronuns, m_IPA.format_IPA_full(lang, IPA_args))
	end
	return m_a.show(dials) .. ' ' .. table.concat(full_pronuns, ' or ')
end

function export.show_full(frame)
	local params = {
		[1] = {default = mw.title.getCurrentTitle().nsText == 'Template' and 'īnspīrāre' or mw.title.getCurrentTitle().text},
		classical = {type = 'boolean', default = true},
		cl = {type = 'boolean', alias_of = 'classical', default = true},
		ecclesiastical = {type = 'boolean', default = true},
		eccl = {type = 'boolean', alias_of = 'ecclesiastical', default = true},
		vul = {type = 'boolean', default = mw.title.getCurrentTitle().nsText == 'Reconstruction'},
		ann = {},
		accent = {list = true},
		indent = {}
	}
	local args = require("Module:parameters").process(frame:getParent().args, params)
	text = args[1]
	local categories = {}
	local accent = args.accent

	local indent = (args.indent or "*") .. " "
	local out = ''
	
	if args.indent then
		out = indent
	end
	
	if args.classical then
		out = out .. make_row(export.phoneticize(text, false, false), #accent > 0 and accent or {'Classical'})
	end
	
	local anntext = (
		args.ann == "1" and "'''" .. rsub(text, "[.'_]", "") .. "''':&#32;" or
		args.ann and "'''" .. args.ann .. "''':&#32;" or
		"")

	out = anntext .. out
	
	if args.eccl then
		out = out .. '\n' .. indent .. anntext .. make_row(
			export.phoneticize(text, true, false),
			#accent > 0 and accent or {'Ecclesiastical'}
		)
		table.insert(categories, lang:getCanonicalName() .. ' terms with Ecclesiastical IPA pronunciation')
	end

	if args.vul then
		out = out .. '\n' .. indent .. anntext .. make_row(
			export.phoneticize(text, false, true),
			#accent > 0 and accent or {'Vulgar'}
		)
		table.insert(categories, lang:getCanonicalName() .. ' terms with Vulgar IPA pronunciation')
	end
	
	return out .. require("Module:utilities").format_categories(categories)
end


function export.convertToIPA(text, phonetic, eccl, vul)
	if type(text) == "table" then -- assume a frame
		eccl = text.args["eccl"]
		vul = text.args["vul"]
		text = text.args[1] or mw.title.getCurrentTitle().text
	end
	
	if vul then
		phonetic = true
	end
	
	return export.convert_words(text, phonetic, eccl, vul)
end


function export.allophone(word, eccl, vul)
	return export.show(word, true, eccl, vul)
end

return export