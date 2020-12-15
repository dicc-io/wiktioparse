local export = {}
local lang = require("Module:languages").getByCode("eo")

-- un-globalifying
local has_vowel, term_to_words, string_to_letters, string_to_syllables,
	string_to_ipa, letters_to_syllables, strip_initial_consonants,
	term_to_IPA_and_rhyme, parse_input, get_artificial_breaks

local consonants = {
	["b"] = "b",
	["c"] = "t͡s",
	["ĉ"] = "t͡ʃ",
	["d"] = "d",
	["f"] = "f",
	["g"] = "ɡ",
	["ĝ"] = "d͡ʒ",
	["h"] = "h",
	["ĥ"] = "x",
	["j"] = "j",
	["ĵ"] = "ʒ",
	["k"] = "k",
	["l"] = "l",
	["m"] = "m",
	["n"] = "n",
	["p"] = "p",
	["r"] = "r",
	["s"] = "s",
	["ŝ"] = "ʃ",
	["t"] = "t",
	["v"] = "v",
	["z"] = "z",
	['ŭ'] = "w"}

local vowels = {
	["a"] = "a",
	["e"] = "e",
	["i"] = "i",
	["o"] = "o",
	["u"] = "u",

}

local letters_phonemes = {}

-- combine into single table
for k, v in pairs(vowels) do letters_phonemes[k] = v end
for k, v in pairs(consonants) do letters_phonemes[k] = v end

function term_to_words(term)
	-- split by spaces, hyphens, or periods
	return mw.text.split(term, '[%s%-%.]')
end
function string_to_letters(term)
	return mw.text.split(term, "")
end

function letters_to_syllables(letters)

	if not letters[2] then
		return {[1] = letters[1]}
	end
	local l_r_exceptions = {["m"] = true, ["n"] = true, ["ŭ"] = true, ["j"] = true}

	local result = {[1] = ""}
	local j = 1
	for i = 1, #letters - 2 do
		result[j] = result[j] .. letters[i]
		local letter = mw.ustring.lower(letters[i])
		local letter1 = mw.ustring.lower(letters[i + 1])
		local letter2 = mw.ustring.lower(letters[i + 2])
		
		if vowels[letter] then
			if consonants[letter1] and vowels[letter2] then
				-- single consonant goes with following vowel
				if has_vowel(result[j]) and (letter1 ~= 'ŭ') then
					j = j + 1
					result[j] = ""
				end
				
			elseif consonants[letter1] and not l_r_exceptions[letter1] and (letter2 == 'l' or letter2 == 'r') and (letter1 ~= 'l' and letter1 ~= 'r') then
				-- consonant followed by l or r goes with l or r
				if has_vowel(result[j]) then
					j = j + 1
					result[j] = ""
				end

			elseif vowels[letter1] then
				-- two vowels
				if has_vowel(result[j]) then
					j = j + 1
					result[j] = ""
				end
			end
		elseif consonants[letter] then
			if consonants[letter1] and vowels[letter2] then
				if (mw.ustring.len(result[j]) ~= 1) then
					-- single consonant goes with following vowel
					if has_vowel(result[j]) then
						j = j + 1
						result[j] = ""
					end
				end
			elseif consonants[letter1] and not l_r_exceptions[letter1] and (letter2 == 'l' or letter2 == 'r') and (letter1 ~= 'l' and letter1 ~= 'r') then
				-- consonant followed by l or r goes with l or r
				if has_vowel(result[j]) then
					j = j + 1
					result[j] = ""
				end

			elseif vowels[letter1] then
				-- two vowels
				if has_vowel(result[j]) then
					j = j + 1
					result[j] = ""
				end
			end
		end
	end
	
	-- add last two letters
	if letters[2] then
		local c1 = letters[#letters - 1]
		local c2 = letters[#letters]
			
		if c1 ~= 'ŭ' then
            if vowels[c1] and vowels[c2] then
                result[j] = result[j] .. c1
                j = j + 1
                result[j] = c2
            elseif has_vowel(result[j]) and has_vowel(c1 .. c2) then
            	j = j + 1
            	result[j] = c1 .. c2
        	else
        		result[j] = result[j] .. c1 .. c2
    		end
        	
        else
            if vowels[letters[#letters - 2]] and vowels[c2] then
            	result[j] = result[j] .. c1
                j = j + 1
                result[j] = c2
            elseif has_vowel(result[j]) and has_vowel(c1 .. c2) then
            	j = j + 1
            	result[j] = c1 .. c2
        	else
        		result[j] = result[j] .. c1 .. c2
    		end
        end
    end
    

	local result2 = {}
	for i, j in pairs(result) do
		if j and j ~= "" then
			table.insert(result2, j)
		end
	end
	return result2
end

function string_to_syllables(term)
	-- split if given artificial syllable breaks
	local split_input = mw.text.split(term, '‧', true)
	local result = {}
	for _, split in pairs(split_input) do
		for j, syllable in pairs(letters_to_syllables(string_to_letters(split))) do
			table.insert(result, syllable)
		end
	end
	
	return result
	
end

function string_to_ipa(syllable)

	local syllable_letters = string_to_letters(syllable)
	local syllable_ipa = ""
	
	for k, letter in pairs(syllable_letters) do
		if letters_phonemes[mw.ustring.lower(letter)] then
			syllable_ipa = syllable_ipa .. letters_phonemes[mw.ustring.lower(letter)]
		end

	end
	return syllable_ipa
end

function has_vowel(term)
	return mw.ustring.lower(term):find("[aeiou]") ~= nil
end

function strip_initial_consonants(term)
	local letters = string_to_letters(term)
	local result = {}
	
	local gate = false
	for i, j in pairs(letters) do
		if vowels[j] then
			gate = true
		end
		
		if gate then
			table.insert(result, j)
		end
	end
	
	return table.concat(result)
end
	

function term_to_IPA_and_rhyme(term)
	
	local words = term_to_words(term)
	local result = {}
	local rhyme_letters

	for i, word in pairs(words) do
		if word ~= "" then
			-- add /o/ if word is a single character and a consonant
			if mw.ustring.len(word) == 1 then
				if consonants[word] then
					word = word .. 'o'
				end
			end
			
			-- break into syllables and make each into IPA
			local hyphenated = string_to_syllables(word)
			local word_result = {}
			for j, syllable in pairs(hyphenated) do
				local syllable_ipa = string_to_ipa(syllable)
				word_result[j] = syllable_ipa
			end

			-- add stress to penultimate syllable, and set rhyme to last two syllables
			if word_result[2] then
				rhyme_letters = strip_initial_consonants(hyphenated[#hyphenated - 1] .. hyphenated[#hyphenated])
				
				word_result[#word_result - 1] = "ˈ" .. word_result[#word_result - 1]
				
            end
            
            return table.concat(word_result)
			
			--result[i] = table.concat(word_result)
		end
	end

	-- rhyme to ipa
	local rhyme = nil
	if rhyme_letters then
		rhyme = string_to_ipa(rhyme_letters)
	end
	
	return result

end

-- function export.term_to_IPA_and_rhyme(word)
--     return term_to_IPA_and_rhyme(word)
-- end

function parse_input(input)
	
	-- no input -> use page title
	return input or mw.title.getCurrentTitle().text
end

function export.IPA(IPA_input)
	IPA_input = mw.ustring.lower(parse_input(IPA_input))
	
	return  "/" .. table.concat(term_to_IPA_and_rhyme(IPA_input).IPA, " ") .. "/"
end

function export.rhyme(rhyme_input)
	rhyme_input = parse_input(rhyme_input)
	
	return term_to_IPA_and_rhyme(rhyme_input).rhyme
end


function export.convertToIPA(word)
    local ret = term_to_IPA_and_rhyme(word)
    return ret
end

function export.hyphenation(hyphenation_input)
	hyphenation_input = parse_input(hyphenation_input)
	
	local words = term_to_words(hyphenation_input)
	local result = {}
	local hyphenated
	
	for i, word in pairs(words) do
		hyphenated = string_to_syllables(word)
		table.insert(result, table.concat(hyphenated, "‧"))
	end
	
	return table.concat(result, ' ')
end

function export.letters(letters_input)
	letters_input = parse_input(letters_input)
	
	return table.concat(string_to_letters(letters_input), '-')
end

function get_artificial_breaks(frame)
	-- override for syllable breaks
	local args = frame:getParent().args
	if not args[1] then
		return nil
	end
	
	param = 1
	local result = {}
	while true do
		if not args[param] then
			if not result then
				return nil
			end
			
			return table.concat(result, "‧")

		end
		table.insert(result, args[param])
		param = param + 1
	end
	
end

function export.pronunciation_section(frame)
	
	local args = frame:getParent().args
	local artificial_breaks = get_artificial_breaks(frame)
	
	IPA_override = args["i"]
	if not IPA_override then
		IPA_override = export.IPA(artificial_breaks)
	end

	hyphenation_override = args["h"]
	if not hyphenation_override then
		hyphenation_override = export.hyphenation(artificial_breaks)
	end
	
	rhyme_override = args["r"]
	if not rhyme_override then
		rhyme_override = export.rhyme(artificial_breaks)
	end
		
	audio = args["a"]

	-- TODO: Use module functions instead.
	if rhyme_override then
		rhyme_override = frame:expandTemplate{ title = "rhymes", args = {"eo", rhyme_override }}
	end
	IPA_override = frame:expandTemplate{ title = "IPA", args = {"eo", IPA_override }}

	local result = "<ul>"
	result = result .. "<li>" .. IPA_override .. "</li>"
	result = result .. "<li>Hyphenation: " .. hyphenation_override .. "</li>"
	
	if rhyme_override then
		result = result .. "<li>" .. rhyme_override .. "</li>"
	end
	
	if audio then
		audio = frame:expandTemplate{ title = "audio", args = {"eo", audio }}
		result = result .. "<li>Audio: " .. audio .. "</li>"
	end
	
	result = result .. "</ul>"
	
	return result
end

return export