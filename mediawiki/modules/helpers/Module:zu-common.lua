local export = {}

local u = mw.ustring.char

local ACUTE     = u(0x0301)
local CIRC      = u(0x0302)
local MACRON    = u(0x0304)
local SYLL      = u(0x0324)

export.diacritic = MACRON .. ACUTE .. CIRC
export.toneless_vowel = "aeiouāēīōūAEIOUĀĒĪŌŪ" .. SYLL
export.vowel = export.toneless_vowel .. "áéíóúḿâêîôûḗṓÁÉÍÓÚḾÂÊÎÔÛḖṒ" .. export.diacritic

function depressor_shift(word, pattern)
	local depressor_consonant = {"bh", "d", "dl", "g", "gc", "gq", "gx", "hh", "j", "mb", "mv", "nd", "ndl", "ng", "ngc", "ngq", "ngx", "nj", "nz", "v", "z"}
	local dep_table = {}
	for i, consonant in ipairs(depressor_consonant) do
		dep_table[consonant] = true
		dep_table[consonant .. "w"] = true
	end
	
	consonants = {}
	for i, syll in ipairs(word) do
		consonant = mw.ustring.sub(syll, 1, #syll-1)
		table.insert(consonants, consonant)
	end
	
	for i, cons in ipairs(consonants) do
		 --If the syllable is H and has a depressor consonant, and next syllable does not have a depressor consonant
		if pattern[i] == "H" and dep_table[cons] and not dep_table[consonants[i+1]] then
			if #consonants - i > 2 then --next syllable is before the penult
				pattern[i] = "L"
				if pattern[i+1] == "L" then
					pattern[i+1] = "H"
				end
			elseif #consonants - i == 2 then --next syllable is penultimate
				pattern[i] = "L"
				if pattern[i+1] == "L" then
					pattern[i+1] = "F"
				end
			-- elseif #consonants - i == 1 then --next syllable is final
				
			end
		end
	end
	
	return pattern
end

function export.split_syllables(word)
	local syllables = {}
	
	for syll in mw.ustring.gmatch(word, "[^" .. export.vowel .. "]*[" .. export.vowel .. "]+") do
		table.insert(syllables, syll)
	end
	
	syllables[#syllables] = syllables[#syllables] .. mw.ustring.match(word, "[^" .. export.vowel .. "]*$")
	
	return syllables
end


function export.apply_tone(word, pattern, shift)
	if shift == nil then
		shift = true
	end
	word = export.split_syllables(word)
	pattern = mw.text.split(pattern or mw.ustring.rep("L", #word), "")
	
	if #word ~= #pattern then
		error("The word \"" .. table.concat(word) .. "\" and the tone pattern " .. table.concat(pattern) .. " have different numbers of syllables.")
	end
	
	if shift then
		pattern = depressor_shift(word, pattern)
	end
	
	for i, tone in ipairs(pattern) do
		if tone == "F" then
			word[i] = mw.ustring.gsub(word[i], "([" .. export.toneless_vowel .. "])", "%1" .. CIRC)
		elseif tone == "H" then
			word[i] = mw.ustring.gsub(word[i], "([" .. export.toneless_vowel .. "])", "%1" .. ACUTE)
		elseif tone ~= "L" then
			error("Invalid character \"" .. tone .. "\" in tone pattern string.")
		end
	end
	
	return (mw.ustring.gsub(mw.ustring.toNFC(table.concat(word)), "̩", ""))
end


return export