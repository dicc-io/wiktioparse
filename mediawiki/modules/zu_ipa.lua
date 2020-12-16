local export = {}

local lang = require("Module:languages").getByCode("zu")


local u = mw.ustring.char

local ACUTE     = u(0x0301)
local CIRC      = u(0x0302)
local MACRON    = u(0x0304)
local CARON     = u(0x030C)
local SYLL      = u(0x0329)

local letters_phonemes = {
	["a"] = "a",
	["e"] = "e",
	["i"] = "i",
	["o"] = "o",
	["u"] = "u",
	
	["c"] = "ǀ", ["ch"] = "ǀʰ", ["nc"] = "ᵑǀ", ["gc"] = "ᶢǀʱ", ["ngc"] = "ᵑǀʱ",
	["q"] = "ǃ", ["qh"] = "ǃʰ", ["nq"] = "ᵑǃ", ["gq"] = "ᶢǃʱ", ["ngq"] = "ᵑǃʱ",
	["x"] = "ǁ", ["xh"] = "ǁʰ", ["nx"] = "ᵑǁ", ["gx"] = "ᶢǁʱ", ["ngx"] = "ᵑǁʱ",
	
	["b"] = "ɓ", ["bh"] = "b", ["mb"] = "mb",
	["d"] = "d", ["dl"] = "ɮ",
	["f"] = "f",
	["g"] = "ɡ", ["ng"] = "nɡ",
	["h"] = "h", ["hh"] = "ɦ", ["hl"] = "ɬ",
	["j"] = "dʒ", ["nj"] = "ɲdʒ", 
	["k"] = "ɠ", ["kh"] = "kʰ", ["kl"] = "kx", ["nk"] = "nk", ["k'"] = "k",
	["l"] = "l",
	["m"] = "m", ["mh"] = "mʱ",
	["n"] = "n", ["nh"] = "nʱ", ["nhl"] = "nɬ",
	["ny"] = "ɲ",
	["p"] = "p", ["ph"] = "pʰ",
	["r"] = "r", 
	["s"] = "s", ["sh"] = "ʃ",
	["t"] = "t", ["th"] = "tʰ",
	["tsh"] = "tʃ", ["ntsh"] = "ɲtʃ",
	["v"] = "v",
	["w"] = "w", ["wh"] = "wʱ",
	["y"] = "j", ["yh"] = "jʱ",
	["z"] = "z",
	["-"] = "ʔ",
	
	["m."] = "m" .. SYLL,
	["m" .. ACUTE] = "m" .. ACUTE .. SYLL,
	['"'] = "ˈ",
	
	[MACRON] = "ː",
	[MACRON .. ACUTE] = ACUTE .. "ː",
	[CIRC] = CIRC .. "ː",
	[CARON] = CARON .. "ː",
}

local function IPA_word(term)
	local rest = mw.ustring.toNFD(term)
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
	
	return mw.ustring.toNFC(table.concat(phonemes))
end

function export.convertToIPA(word)
    return IPA_word(word)
end

function export.IPA(frame)
	local args = frame:getParent().args
	local term
	local tone_needed = ""
	if args[1] then
		term = args[1]
	else
		term = mw.ustring.lower(mw.title.getCurrentTitle().subpageText)
		tone_needed = "<sup title=\"tones missing\">?</sup>"
	end
	
	if not (mw.ustring.find(term, '"') or mw.ustring.find(term, "[āēīōūâêîôûā́ḗī́ṓū́]$")) then
		-- Penultimate lengthening
		term = require("Module:zu-common").split_syllables(term)
		
		if term[2] then
			term[#term - 1] = mw.ustring.gsub(term[#term - 1], "[aeiouáéíóú]$", {["a"] = "ā", ["e"] = "ē", ["i"] = "ī", ["o"] = "ō", ["u"] = "ū", ["á"] = "ā́", ["é"] = "ḗ", ["í"] = "ī́", ["ó"] = "ṓ", ["ú"] = "ū́"})
		end
		
		term = table.concat(term)
	end
	
	term = IPA_word(term)
	return require("Module:IPA").format_IPA_full(lang, {{pron = "/" .. term .. "/"}}) .. tone_needed
end


return export