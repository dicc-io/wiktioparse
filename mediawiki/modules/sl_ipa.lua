local export = {}

local lang = require("Module:languages").getByCode("sl")
local u = mw.ustring.char

local GRAVE		= u(0x0300)
local ACUTE		= u(0x0301)
local MACRON	= u(0x0304)
local CARON		= u(0x030C)
local DGRAVE	= u(0x030F)
local INVBREVE	= u(0x0311)
local DOTBELOW  = u(0x0323)
local DIACRITIC = GRAVE .. ACUTE .. MACRON .. DGRAVE .. INVBREVE


local letters_phonemes = {
	["e"] = "ɛ", ["ẹ"] = "e",
	["o"] = "ɔ", ["ọ"] = "o",
	
	["c"] = "t͡s",
	["č"] = "t͡ʃ",
	["dž"] = "d͡ʒ",
	["g"] = "ɡ",
	["h"] = "x",
	["ł"] = "ʋ",
	["ər" .. ACUTE] = "ə̀r",
	["ər" .. INVBREVE] = "ə́r",
	["š"] = "ʃ",
	["v"] = "ʋ",
	["ž"] = "ʒ",
	[GRAVE] = GRAVE,
	[DGRAVE] = ACUTE,
	[ACUTE] = GRAVE .. "ː",
	[INVBREVE] = ACUTE .. "ː",
	
	["."] = "",
}

--	This adds letters_phonemes["e"] = "e", letters_phonemes["i"] = "i", etc.
for letter in mw.ustring.gmatch("abdfijklmnprstuzə", ".") do
	letters_phonemes[letter] = letter
end

local devoicing = {
	["b"] = "p",
	["d"] = "t",
	["g"] = "k",
	["z"] = "s",
	["ž"] = "š",
}

local voicing = {
	["c"] = "dz",
	["č"] = "dž",
	["f"] = "v",
}

for key, val in pairs(devoicing) do
	voicing[val] = key
end

local function to_IPA(text)
	-- Recompose č, š, ž
	text = text:gsub("c" .. CARON, "č")
	text = text:gsub("s" .. CARON, "š")
	text = text:gsub("z" .. CARON, "ž")
	
	-- Recompose ẹ, ọ
	text = text:gsub("e" .. DOTBELOW, "ẹ")
	text = text:gsub("o" .. DOTBELOW, "ọ")
	
	-- Apply final devoicing
	text = mw.ustring.gsub(text, "[bdgzž]$", devoicing)
	
	-- Voicing assimilation
	local matches
	
	while true do
		text, matches = mw.ustring.gsub(text, "([bdgzž])([cčfkpsšt])", function (first, second) return devoicing[first] .. second end)
		
		if matches == 0 then
			break
		end
	end
	
	while true do
		text, matches = mw.ustring.gsub(text, "([cčfkpsšt])([bdgzž])", function (first, second) return voicing[first] .. second end)
		
		if matches == 0 then
			break
		end
	end
	
	-- Syllabic r
	text = mw.ustring.gsub(text, "r([" .. ACUTE .. MACRON .. INVBREVE .. "])", "ər%1")
	text = mw.ustring.gsub(text, "^r([^aeiouẹọə])", "ər%1")
	text = mw.ustring.gsub(text, "([^aeiouẹọə" .. DIACRITIC .. "])r([^aeiouẹọə])", "%1ər%2")
	
	-- lj, nj when not followed by a vowel
	text = mw.ustring.gsub(text, "([ln])j$", "%1")
	text = mw.ustring.gsub(text, "([ln])j([^aeiouẹọə])", "%1%2")
	
	-- Convert to IPA
	local rest = text
	local phonemes = {}
	
	while mw.ustring.len(rest) > 0 do
		-- Find the longest string of letters that matches a recognised sequence in the list
		local longestmatch = ""
		
		for letter, phoneme in pairs(letters_phonemes) do
			if mw.ustring.sub(rest, 1, mw.ustring.len(letter)) == letter and mw.ustring.len(letter) > mw.ustring.len(longestmatch) then
				longestmatch = letter
			end
		end
		
		if mw.ustring.len(longestmatch) > 0 then
			table.insert(phonemes, letters_phonemes[longestmatch])
			rest = mw.ustring.sub(rest, mw.ustring.len(longestmatch) + 1)
		else
			table.insert(phonemes, mw.ustring.sub(rest, 1, 1))
			rest = mw.ustring.sub(rest, 2)
		end
	end
	
	return table.concat(phonemes)
end

function export.convertToIPA(word)
    return to_IPA(word)
end

function export.IPA(frame)
	local params = {
		[1] = {list = true, required = true},
	}
	
	local args = require("Module:parameters").process(frame:getParent().args, params)
	
	local items = {}
	
	for _, text in ipairs(args[1]) do
		if lang:makeEntryName(text) ~= mw.title.getCurrentTitle().text then
			require("Module:debug").track("sl-IPA/mismatch")
		end
		
		if mw.ustring.find(text, "[əł]") then
			require("Module:debug").track("sl-IPA/special")
			
			if #args[1] == 1 then
				if mw.ustring.find(text, "ə") then
					require("Module:debug").track("sl-IPA/special/ə")
				end
				
				if mw.ustring.find(text, "ł") then
					require("Module:debug").track("sl-IPA/special/ł")
				end
			else
				require("Module:debug").track("sl-IPA/special/multiple")
			end
		end
		
		text = mw.ustring.lower(text)
		text = mw.ustring.toNFD(text)
		
		local _, number_of_macrons = mw.ustring.gsub(text, MACRON, "")
		
		if number_of_macrons == 1 then
			table.insert(items, {pron = "/" .. to_IPA((text:gsub(MACRON, ACUTE))) .. "/"})
			table.insert(items, {pron = "/" .. to_IPA((text:gsub(MACRON, INVBREVE))) .. "/"})
		elseif number_of_macrons == 0 then
			table.insert(items, {pron = "/" .. to_IPA(text) .. "/"})
		else
			error("The term may contain at most one macron")
		end
	end
	
	return require("Module:IPA").format_IPA_full(lang, items)
end

return export