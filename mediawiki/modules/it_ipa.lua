
local export = {}

local stress = "ˈ"
local long = "ː"
local acute = mw.ustring.char(0x301)
local grave = mw.ustring.char(0x300)
local circumflex = mw.ustring.char(0x302)
local acute_or_grave = "[" .. acute .. grave .. "]"
local vowels = "aeɛioɔu"
local vowel = "[" .. vowels .. "]"
local vowel_or_semivowel = "[" .. vowels .. "jw]"
local not_vowel = "[^" .. vowels .. "]"
local front = "[eɛij]"
local fronted = mw.ustring.char(0x031F)
local voiced_consonant = "[bdɡlmnrv]"

local full_affricates = { ["ʦ"] = "t͡s", ["ʣ"] = "d͡z", ["ʧ"] = "t͡ʃ", ["ʤ"] = "d͡ʒ" }

-- ʦ, ʣ, ʧ, ʤ used for
-- t͡s, d͡z, t͡ʃ, d͡ʒ in body of function.

-- voiced_z must be a table of integer indices, a boolean, or nil.
function export.convertToIPA(word, voiced_z, single_character_affricates)
	word = mw.ustring.lower(word):gsub("'", "")
	
	-- Decompose combining characters: for instance, è → e + ◌̀
	local decomposed = mw.ustring.toNFD(word):gsub("x", "ks"):gsub("y", "i")
		:gsub("ck", "k"):gsub("sh", "ʃ"):gsub("ng$", "ŋ")
	local all_z_voiced
	if type(voiced_z) == "boolean" then
		all_z_voiced = voiced_z
		voiced_z = nil
	else
		require "libraryUtil".checkTypeMulti("to_IPA", 2, voiced_z,
			{ "table", "boolean", "nil" })
	end
	
	-- Transcriptions must contain an acute or grave, to indicate stress position.
	-- This does not handle phrases containing more than one stressed word.
	-- Default to penultimate stress rather than throw error?
	local vowel_count
	if not mw.ustring.find(decomposed, acute_or_grave) then
		-- Allow monosyllabic unstressed words.
		vowel_count = select(2, decomposed:gsub("[aeiou]", "%1"))
		if vowel_count ~= 1 then
			-- Add acute accent on second-to-last vowel.
			decomposed = mw.ustring.gsub(decomposed, 
				"(" .. vowel .. ")(" .. not_vowel .. "*[iu]?" .. vowel .. not_vowel .. "*)$",
				"%1" .. acute .. "%2")
		end
	end
	
	local transcription = decomposed
	
	-- Assume that aw is English.
	transcription = mw.ustring.gsub(
		transcription,
		"a(" .. grave .. "?)w",
		{ [""] = vowel_count == 1 and "ɔ" or "o", [grave] = "ɔ"})
	
	-- Handle è, ò.
	transcription = transcription:gsub("([eo])(" .. grave .. ")",
		function (vowel, accent)
			return ({ e = "ɛ", o = "ɔ" })[vowel] .. accent
		end) -- e or o followed by grave
	
	-- ci, gi + vowel
	-- Do ci, gi + e, é, è sometimes contain /j/?
	transcription = mw.ustring.gsub(transcription,
		"([cg])([cg]?)i(" .. vowel .. ")",
		function (consonant, double, vowel)
			local out_consonant
			if consonant == "c" then
				out_consonant = "ʧ"
			else
				out_consonant = "ʤ"
			end
			
			if double ~= "" then
				if double ~= consonant then
					error("Invalid sequence " .. consonant .. double .. ".")
				end
				
				out_consonant = out_consonant .. out_consonant
			end
			
			return out_consonant .. vowel
		end)
	
	-- Handle gl and gn.
	transcription = mw.ustring.gsub(transcription,
		"(g[nl])(.?)()",
		function (digraph, after, pos)
			local consonant
			if digraph == "gn" then
				consonant = "ɲ"
			
			-- gli is /ʎi/, or /ʎ/ before a vowel
			elseif after == "i" then
				consonant = "ʎ"
				
				local following = mw.ustring.sub(transcription, pos, pos)
				if following ~= "" and vowels:find(following) then
					after = ""
				end
			end
			
			if consonant then
				return consonant .. after
			end
		end)
	
	-- Handle other cases of c, g.
	transcription = mw.ustring.gsub(transcription,
		"(([cg])([cg]?)(h?))(.?)",
		function (consonant, first, double, second, next)
			-- Don't allow the combinations cg, gc.
			-- Or do something else?
			if double ~= "" and double ~= first then
				error("Invalid sequence " .. first .. double .. ".")
			end
			
			-- c, g is soft before e, i.
			local consonant
			if (next == "e" or next == "ɛ" or next == "i") and second ~= "h" then
				if first == "c" then
					consonant = "ʧ"
				else
					consonant = "ʤ"
				end
			else
				if first == "c" then
					consonant = "k"
				else
					consonant = "ɡ"
				end
			end
			
			if double ~= "" then
				consonant = consonant .. consonant
			end
			
			return consonant .. next
		end)
	
	-- ⟨qu⟩ represents /kw/.
	transcription = transcription:gsub("qu", "kw")
	
	-- u or i (without accent) before another vowel is a semivowel.
	-- ci, gi + vowel, gli, qu must be dealt with beforehand.
	transcription = mw.ustring.gsub(transcription,
		"([iu])(" .. vowel .. ")",
		function (semivowel, vowel)
			if semivowel == "i" then
				semivowel = "j"
			else
				semivowel = "w"
			end
			
			return semivowel .. vowel
		end)
	
	-- sc before e, i is /ʃ/, doubled after a vowel.
	transcription = transcription:gsub("sʧ", "ʃ")
	
	-- ⟨z⟩ represents /t͡s/ or /d͡z/; no way to determine which.
	-- For now, /t͡s/ is the default.
	local before_izzare = mw.ustring.match(
		transcription,
		"(.-" .. vowel .. not_vowel .. "*)izza" .. acute_or_grave .. "?re$")
	if before_izzare then
		transcription = before_izzare
	end
	
	local z_index = 0
	transcription = mw.ustring.gsub(
		transcription,
		"()(z+)(.?)",
		function (pos, z, after)
			local length = #z
			if length > 2 then
				error("Too many z's in a row!")
			end
			
			z_index = z_index + 1
			local voiced = voiced_z and require "Module:table".contains(voiced_z, z_index)
					or all_z_voiced
			
			if pos == 1 then
				if mw.ustring.find(transcription, "^[ij]" .. acute_or_grave .. "?" .. vowel, pos + #z) then
					voiced = false
				elseif mw.ustring.find(transcription, "^" .. vowel .. acute_or_grave .. "?" .. vowel, pos + #z) then
					voiced = true
				end
				-- check whether followed by two vowels
				-- check onset of next syllable
			else
				if mw.ustring.find(after, vowel_or_semivowel) then
					
					local before = mw.ustring.sub(transcription, pos - 2, pos - 1)
					
					if mw.ustring.find(before, vowel_or_semivowel .. acute_or_grave .. "?$") then
						if length == 1 and mw.ustring.find(after, vowel)
						and mw.ustring.find(before, vowel) then
							voiced = true
						end
						
						length = 2
					end
					
					if mw.ustring.sub(transcription, pos + #z, pos + #z + 1) == "i" .. circumflex then
						voiced = false
					end
				end
			end
			
			return (voiced and "ʣ" or "ʦ"):rep(length) .. after
		end)
	
	if before_izzare then
		transcription = transcription .. mw.ustring.toNFD("iʣʣàre")
	end
	
	-- Replace acute and grave with stress mark.
	transcription = mw.ustring.gsub(transcription,
		"(" .. vowel .. ")" .. acute_or_grave, stress .. "%1")
	
	-- Single ⟨s⟩ between vowels is /z/.
	transcription = mw.ustring.gsub(transcription,
		"(" .. vowel .. ")s(" .. stress .. "?" .. vowel .. ")", "%1z%2")
	
	-- ⟨s⟩ immediately before a voiced consonant is always /z/
	transcription = mw.ustring.gsub(transcription,
		"s(" .. voiced_consonant .. ")", "z%1")
	
	-- After a vowel, /ʃ ʎ ɲ/ are doubled.
	-- [[w:Italian phonology]] says word-internally, [[w:Help:IPA/Italian]] says
	-- after a vowel.
	transcription = mw.ustring.gsub(transcription,
		"(" .. vowel .. ")([ʃʎɲ])", "%1%2%2")
	
	-- Move stress before syllable onset, and add syllable breaks.
	-- This rule may need refinement.
	transcription = mw.ustring.gsub(transcription,
		"()(" .. not_vowel .. "?)([^" .. vowels .. stress .. "]*)(" .. stress
			.. "?)(" .. vowel .. ")",
		function (position, first, rest, syllable_divider, vowel)
			-- beginning of word, that is, at the moment, beginning of string
			if position == 1 then
				return syllable_divider .. first .. rest .. vowel
			end
			
			if syllable_divider == "" then
				syllable_divider = "."
			end
			
			if rest == "" then
				return syllable_divider .. first .. vowel
			else
				return first .. syllable_divider .. rest .. vowel
			end
		end)
	
	if not single_character_affricates then
		transcription = mw.ustring.gsub(transcription, "([ʦʣʧʤ])([%." .. stress .. "]*)([ʦʣʧʤ]*)",
			function (affricate1, divider, affricate2)
				local full_affricate = full_affricates[affricate1]
				
				if affricate2 ~= "" then
					return mw.ustring.sub(full_affricate, 1, 1) .. divider .. full_affricate
				end
				
				return full_affricate .. divider
			end)
	end
	
	transcription = mw.ustring.gsub(transcription, "[h%-" .. circumflex .. "]", "")
	transcription = transcription:gsub("%.ˈ", "ˈ")
	
	return transcription
end

-- Incomplete and currently not used by any templates.
function export.to_phonetic(word, voiced_z)
	local phonetic = export.to_phonemic(word, voiced_z)
	
	-- Vowels longer in stressed, open, non-word-final syllables.
	phonetic = mw.ustring.gsub(phonetic,
		"(" .. stress .. not_vowel .. "*" .. vowel .. ")([" .. vowels .. "%.])",
		"%1" .. long .. "%2")
	
	-- /n/ before /ɡ/ or /k/ is [ŋ]
	phonetic = mw.ustring.gsub(phonetic,
		"n([%.ˈ]?[ɡk])", "ŋ%1")

	-- Imperfect: doesn't convert geminated k, g properly.
	phonetic = mw.ustring.gsub(phonetic,
			"([kg])(" .. front .. ")",
			"%1" .. fronted .. "%2")
		:gsub("a", "ä")
		:gsub("n", "n̺") -- Converts n before a consonant, which is incorrect.
	
	return phonetic
end

function export.show(frame)
	local m_IPA = require "Module:IPA"
	
	local args = require "Module:parameters".process(
		frame:getParent().args,
		{
			-- words to transcribe
			[1] = { list = true, default = mw.title.getCurrentTitle().text },
			
			-- each parameter a series of numbers separated by commas,
			-- or a boolean, indicating that a particular z is voiced or
			-- that all of them are
			voiced = { list = true },
		})
	
	local Array = require "Module:array"
	
	local voiced_z = Array(args.voiced)
		:map(function (param)
			param = Array(mw.text.split(param, "%s*,%s*"))
				:map(
					function (item, i)
						return tonumber(item)
							or i == 1 and require "Module:yesno"(item) -- Rejects false values.
							or error("Invalid input '" .. item .."' in |voiced= parameter. "
								.. "Expected number or boolean.")
					end)
			
			if not param[2] and type(param[1]) == "boolean" then
				param = param[1]
			end
			
			return param
		end)
	
	local transcriptions = Array(args[1])
		:map(
			function (word, i)
				return { pron = "/" .. export.to_phonemic(word, voiced_z[i]) .. "/" }
			end)
	
	return m_IPA.format_IPA_full(
		require "Module:languages".getByCode "it", transcriptions)
end

return export