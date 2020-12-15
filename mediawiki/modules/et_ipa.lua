local export = {}

local m_IPA = require("Module:IPA")
local lang = require("Module:languages").getByCode("et")

local letters_phonemes = {
	["a"] = "ɑ", ["aa"] = "ɑː",
	["e"] = "e", ["ee"] = "eː",
	["i"] = "i", ["ii"] = "iː",
	["o"] = "o", ["oo"] = "oː",
	["u"] = "u", ["uu"] = "uː",
	["õ"] = "ɤ", ["õõ"] = "ɤː",
	["ä"] = "æ", ["ää"] = "æː",
	["ö"] = "ø", ["öö"] = "øː",
	["ü"] = "y", ["üü"] = "yː",
	
	["ea"] = "eɑ̯",
	["oa"] = "oɑ̯",
	["õa"] = "ɤɑ̯",
	["öa"] = "øɑ̯",
	["üa"] = "yɑ̯",
	
	["ae"] = "ɑe̯",
	["oe"] = "oe̯",
	["õe"] = "ɤe̯",
	["äe"] = "æe̯",
	["öe"] = "øe̯",
	
	["ai"] = "ɑi̯",
	["ei"] = "ei̯",
	["oi"] = "oi̯",
	["ui"] = "ui̯",
	["õi"] = "ɤi̯",
	["äi"] = "æi̯",
	["öi"] = "øi̯",
	["üi"] = "yi̯",
	
	["ao"] = "ɑo̯",
	["eo"] = "eo̯",
	["uo"] = "uo̯",
	["õo"] = "ɤo̯",
	["äo"] = "æo̯",
	
	["au"] = "ɑu̯",
	["iu"] = "iu̯",
	["ou"] = "ou̯",
	["õu"] = "ɤu̯",
	["äu"] = "æu̯",
	
	["b"]  = "b̥",
	["d"]  = "d̥",
	["d'"] = "d̥ʲ",
	["g"]  = "ɡ̊",
	
	["p"]  = "p" , ["pp"]  = "pː",
	["t"]  = "t" , ["tt"]  = "tː",
	["t'"] = "tʲ", ["t't"] = "tʲː",
	["k"]  = "k" , ["kk"]  = "kː",
	
	["f"]  = "f" , ["ff"]  = "fː",
	["h"]  = "h" , ["hh"]  = "hː",
	["s"]  = "s" , ["ss"]  = "sː",
	["s'"] = "sʲ", ["s's"] = "sʲː",
	
	["l"]  = "l",  ["ll"]  = "lː",
	["l'"] = "lʲ", ["l'l"] = "lʲː",
	["r"]  = "r",  ["rr"]  = "rː",
	["m"]  = "m",  ["mm"]  = "mː",
	["n"]  = "n",  ["nn"]  = "nː",
	["n'"] = "nʲ", ["n'n"]  = "nʲː",
	["j"]  = "j",  ["jj"]  = "jː",
	["v"]  = "v",  ["vv"]  = "vː",
	
	["š"] = "ʃ", ["šš"] = "ʃː",
	["ž"] = "ʒ", ["žž"] = "ʒː",
	
	["´"] = "ˈ", ["`"] = "ˈ",
}

local function IPA_word(word)
	-- Make everything lowercase so we don't have to deal with case differences
	word = mw.ustring.lower(word)
	
	local rest = word
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
			-- If no match was found, just insert the character as it is
			table.insert(phonemes, mw.ustring.sub(rest, 1, 1))
			rest = mw.ustring.sub(rest, 2)
		end
	end
	
	local ipa = table.concat(phonemes)
	
	-- Add default stress mark is one is not already present
	if not mw.ustring.find(ipa, "ˈ") then
		ipa = "ˈ" .. ipa
	end
	
	return ipa
end

function export.convertToIPA(word)
    return IPA_word(word)
end


function export.IPA(frame)
	local words = {}
	
	for _, word in ipairs(frame:getParent().args) do
		table.insert(words, word)
	end
	
	if #words == 0 then
		words = {mw.title.getCurrentTitle().text}
	end
	
	for key, word in ipairs(words) do
		words[key] = IPA_word(word)
	end
	
	return m_IPA.format_IPA_full(lang, {{pron = "/" .. table.concat(words) .. "/"}})
end

return export