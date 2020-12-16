local export = {}

local lang = require("Module:languages").getByCode("is")
local sc = require("Module:scripts").getByCode("Latn")

function export.tag_text(text, face)
	return require("Module:script utilities").tag_text(text, lang, sc, face)
end

function export.link(term, face)
	return require("Module:links").full_link( { term = term, lang = lang, sc = sc }, face )
end

local sub = mw.ustring.sub
local find = mw.ustring.find
local gmatch = mw.ustring.gmatch
local gsub = mw.ustring.gsub

local U = mw.ustring.char
local nonsyllabic = U(0x32F)		-- inverted breve below
local retracted = U(0x320)			-- minus sign below
local voiceless = U(0x325)			-- combining ring below
local voiceless_above = U(0x30A)	-- combining ring above
local habove = "ʰ"
local long = "ː"
local primary_stress = "ˈ"

local consonants = "bdðfghjklmnprstvxþ"
local consonant = "[" .. consonants .. "]"

local vowels = "aɛɪiʏyœɔou"
local vowel = "[" .. vowels .. "]+" .. "[" .. nonsyllabic .. "]?"

-- Phonemic WORK IN PROGRESS
data_m = {
	["initial"] = {
		["b"] = "p",
		["d"] = "t",
		["g"] = "k",
		["p"] = "pʰ",
		["t"] = "tʰ",
		["k"] = "kʰ",
--		["f"] = "f",
		["gj"] = "c",
		["kj"] = "cʰ",
		["hv"] = "kv",
		["þ"] = "θ"--[[ .. retracted]],
		["hl"] = "l" .. voiceless,
		["hn"] = "n" .. voiceless,
		["hr"] = "r" .. voiceless,
		["hj"] = "ç",
		[""] = "",
	},
	["internal"] = {
--		["ð"] = "ð" .. retracted,
		["b"] = "p",
		["d"] = "t",
		["x"] = "xs",
		["f"] = "v",
		["þ"] = "θ"--[[ .. retracted]],
		[""] = "",
		[""] = "",
		[""] = "",
	},
	["vowels"] = {
		["a"] = "a",
		["á"] = "au" .. nonsyllabic,
		["e"] = "ɛ",
		["é"] = "jɛ",
		["i"] = "ɪ",
		["y"] = "ɪ",
		["í"] = "i",
		["ý"] = "i",
		["o"] = "ɔ",
		["ó"] = "ou" .. nonsyllabic,
		["u"] = "ʏ",
		["ú"] = "u",
		["æ"] = "ai" .. nonsyllabic,
		["ö"] = "œ",
	},
	["before_ng"] = {
		["a"] = "au" .. nonsyllabic,
		["e"] = "ɛi" .. nonsyllabic,
		["u"] = "u",
		["i"] = "i",
		["y"] = "i",
		["ö"] = "œy" .. nonsyllabic,
	},
	["digraphs"] = {
		["bb"] = "p",
		["dd"] = "t",
		["kj"] = "c",
		["ll"] = "tl" .. voiceless,
		["rn"] = "rtn" .. voiceless,
		["rl"] = "rtl" .. voiceless,
		["sl"] = "stl" .. voiceless,
		["sn"] = "stn" .. voiceless,
		["tn"] = "ʰtn" .. voiceless,
		["au"] = "œy" .. nonsyllabic,
		["ei"] = "ɛi" .. nonsyllabic,
		["ey"] = "ɛi" .. nonsyllabic,
	},
	["trigraphs"] = {
		["fnd"] = "mt",
		["fnt"] = "m" .. voiceless .. "t",
	},
	["long"] = {
		["a"] = "a" .. long,
		["ɛ"] = "eɛ" .. nonsyllabic,
	},
}

-- Phonetic
data_t = {
	["initial"] = {
		["b"] = "p",
		["d"] = "t",
		["g"] = "k",
		["p"] = "pʰ",
		["t"] = "tʰ",
		["k"] = "kʰ",
--		["f"] = "f",
		["gj"] = "c",
		["kj"] = "cʰ",
		["hv"] = "kv",
		["þ"] = "θ"--[[ .. retracted]],
		["hl"] = "l" .. voiceless,
		["hn"] = "n" .. voiceless,
		["hr"] = "r" .. voiceless,
		["hj"] = "ç",
		[""] = "",
	},
	["internal"] = {
--		["ð"] = "ð" .. retracted,
		["b"] = "p",
		["d"] = "t",
		["x"] = "xs",
		["f"] = "v",
		["þ"] = "θ"--[[ .. retracted]],
		[""] = "",
		[""] = "",
		[""] = "",
	},
	["vowels"] = {
		["a"] = "a",
		["á"] = "au" .. nonsyllabic,
		["e"] = "ɛ",
		["é"] = "jɛ",
		["i"] = "ɪ",
		["y"] = "ɪ",
		["í"] = "i",
		["ý"] = "i",
		["o"] = "ɔ",
		["ó"] = "ou" .. nonsyllabic,
		["u"] = "ʏ",
		["ú"] = "u",
		["æ"] = "ai" .. nonsyllabic,
		["ö"] = "œ",
	},
	["longvowels"] = {
		["a"] = "a" .. long,
		["á"] = "au" .. long .. nonsyllabic,
		["e"] = "ɛ" .. long,
		["é"] = "jɛ" .. long,
		["i"] = "ɪ" .. long,
		["y"] = "ɪ" .. long,
		["í"] = "i" .. long,
		["ý"] = "i" .. long,
		["o"] = "ɔ" .. long,
		["ó"] = "ou" .. long .. nonsyllabic,
		["u"] = "ʏ" .. long,
		["ú"] = "u" .. long,
		["æ"] = "ai" .. long .. nonsyllabic,
		["ö"] = "œ" .. long,
	},
	["before_ng"] = {
		["a"] = "au" .. nonsyllabic,
		["e"] = "ɛi" .. nonsyllabic,
		["u"] = "u",
		["i"] = "i",
		["y"] = "i",
		["ö"] = "œy" .. nonsyllabic,
	},
	["digraphs"] = {
		["bb"] = "p",
		["dd"] = "t",
		["kj"] = "c",
		["ll"] = "tl" .. voiceless,
		["rn"] = "rtn" .. voiceless,
		["rl"] = "rtl" .. voiceless,
		["sl"] = "stl" .. voiceless,
		["sn"] = "stn" .. voiceless,
		["tn"] = "ʰtn" .. voiceless,
		["au"] = "œy" .. nonsyllabic,
		["ei"] = "ɛi" .. nonsyllabic,
		["ey"] = "ɛi" .. nonsyllabic,
	},
	["trigraphs"] = {
		["fnd"] = "mt",
		["fnt"] = "m" .. voiceless .. "t",
		["ánn"] = "au" .. nonsyllabic .. "tn" .. voiceless,
		["énn"] = "jɛtn" .. voiceless,
		["ínn"] = "itn" .. voiceless,
		["ónn"] = "ou" .. nonsyllabic .. "tn" .. voiceless,
		["únn"] = "utn" .. voiceless,
		["ýnn"] = "itn" .. voiceless,
		["l-l"] = "l"
	},
	["long"] = {
		["a"] = "a" .. long,
		["ɛ"] = "eɛ" .. nonsyllabic,
	},
}

-- add data for preaspirated stops
for letter in gmatch("ptk", ".") do
	data_t.digraphs[letter .. letter] = "ʰ" .. letter
	data_t.digraphs[letter .. "n"] = "ʰ" .. letter .. "n"
	data_m.digraphs[letter .. letter] = "h" .. letter
	data_m.digraphs[letter .. "n"] = "h" .. letter .. "n"
end

-- Phonemic WORK IN PROGRESS
rules_m = {
	[1] = {
		["(" .. primary_stress .. consonant .. "*" .. vowel .. ")nn"]
			=
			"%1tn"--[[ .. voiceless]],
		["(" .. vowel .. ")" .. "g" .. "([aʏðlr])"] = "%1ɣ%2",
		["(" .. vowel .. ")" .. "g" .. "([ji])"] = "%1j%2",
		["(" .. vowel .. ")" .. "[kg]" .. "([ts])"] = "%1x%2",
		["(" .. vowel .. ")" .. "p" .. "([tsk])"] = "%1f%2",
		["ng([ls])"] = "ŋ%1"
	},
	[2] = {
		["(u" .. nonsyllabic .. "?)[vɣ]"] = "%1",
		["g"] = "k",
	},
	[3] = {
		["k(ʰ?[ɛiɪ])"] = "c%1",
		["k(ʰ?ai)"] = "c%1",
		["k(ʰ?[ɛiɪ])"] = "c%1",
		["k(ʰ?ai)"] = "c%1",
		["kj"] = "c",
		["jj"] = "i" .. nonsyllabic .. "j"
	},
	[4] = {
		["nk"] = "ŋk",
		["kc"] = "cc",
	}
}

-- Phonetic
rules_t = {
	[1] = {
		["(" .. consonant .. "*" .. vowel .. vowel .. ")nn"]
			=
			"%1tn".. voiceless,
		["(" .. vowel .. ")" .. "g" .. "([aʏðlr])"] = "%1ɣ%2",
		["(" .. vowel .. ")" .. "g" .. "([ji])"] = "%1j%2",
		["(" .. vowel .. ")" .. "[kg]" .. "([ts])"] = "%1x%2",
		["(" .. vowel .. ")" .. "p" .. "([tsk])"] = "%1f%2",
		["ng([ls])"] = "ŋ%1"
	},
	[2] = {
		["nn"]
			=
			"n".. long,
		["(u" .. nonsyllabic .. "?)[vɣ]"] = "%1",
		["g"] = "k",
	},
	[3] = {
		["k(ʰ?[ɛiɪ])"] = "c%1",
		["k(ʰ?ai)"] = "c%1",
		["k(ʰ?[ɛiɪ])"] = "c%1",
		["k(ʰ?ai)"] = "c%1",
		["kj"] = "c",
		["jj"] = "i" .. nonsyllabic .. "j"
	},
	[4] = {
		["nk"] = "ŋk",
		["kc"] = "c",
		["pn"] = "pn" .. voiceless
	}
}

-- mode = "t" for phonetic or "m" for phonemic
function export.toIPA(mode, term, accent)
	if type(term) ~= "string" then
		error('The function "toIPA" requires a string argument.')
	end
	
	local IPA = {}
	
	if accent ~= "off" then
		table.insert(IPA, primary_stress)
	end
	
	local working_string = mw.ustring.lower(term)
	local firstletter = sub(working_string, 1, 1)
	local firsttwoletters = sub(working_string, 1, 2)
	if mode == "t" then
		if find(firstletter, consonant) then
			if data_t.initial[firsttwoletters] then
				table.insert(IPA, data_t.initial[firsttwoletters])
				working_string = sub(working_string, 3)
			elseif data_t.initial[firstletter] then
				table.insert(IPA, data_t.initial[firstletter])
				working_string = sub(working_string, 2)
			else
				table.insert(IPA, firstletter)
				working_string = sub(working_string, 2)
			end
		end
	
		while mw.ustring.len(working_string) > 0 do
			local letter = { sub(working_string, 1, 1), sub(working_string, 2, 3) }
			local twoletters = { sub(working_string, 1, 2), sub(working_string, 3, 4) }
			local threeletters = { sub(working_string, 1, 3), sub(working_string, 4, 5) }
		
			if data_t.trigraphs[threeletters[1]] then
				table.insert(IPA, data_t.trigraphs[threeletters[1]])
				working_string = sub(working_string, 4)
			elseif data_t.digraphs[twoletters[1]] then
				table.insert(IPA, data_t.digraphs[twoletters[1]])
				working_string = sub(working_string, 3)
			elseif data_t.vowels[letter[1]] then
				if data_t.before_ng[letter[1]] and ( letter[2] == "nk" or letter[2] == "ng" ) then
					table.insert(IPA, data_t.before_ng[letter[1]])
				elseif data_t.longvowels[letter[1]] and (not data_t.vowels[letter[2]]) and data_t.vowels[letter[3]] then
					table.insert(IPA, data_t.longvowels[letter[1]])
				else
					table.insert(IPA, data_t.vowels[letter[1]])
				end
				working_string = sub(working_string, 2)
			elseif data_t.internal[letter[1]] then
				table.insert(IPA, data_t.internal[letter[1]])
				working_string = sub(working_string, 2)
			else
				table.insert(IPA, letter[1])
				working_string = sub(working_string, 2)
			end
		end
		IPA = table.concat(IPA)
		for ordering, set_of_rules in ipairs(rules_t) do
			for regex, replacement in pairs(set_of_rules) do
				IPA = gsub(IPA, regex, replacement)
			end
		end
	elseif mode == "m" then
		if find(firstletter, consonant) then
			if data_m.initial[firsttwoletters] then
				table.insert(IPA, data_m.initial[firsttwoletters])
				working_string = sub(working_string, 3)
			elseif data_m.initial[firstletter] then
				table.insert(IPA, data_m.initial[firstletter])
				working_string = sub(working_string, 2)
			else
				table.insert(IPA, firstletter)
				working_string = sub(working_string, 2)
			end
		end
	
		while mw.ustring.len(working_string) > 0 do
			local letter = { sub(working_string, 1, 1), sub(working_string, 2, 3) }
			local twoletters = { sub(working_string, 1, 2), sub(working_string, 3, 4) }
			local threeletters = { sub(working_string, 1, 3), sub(working_string, 4, 5) }
		
			if data_m.trigraphs[threeletters[1]] then
				table.insert(IPA, data_m.trigraphs[threeletters[1]])
				working_string = sub(working_string, 4)
			elseif data_m.digraphs[twoletters[1]] then
				table.insert(IPA, data_m.digraphs[twoletters[1]])
				working_string = sub(working_string, 3)
			elseif data_m.vowels[letter[1]] then
				if data_m.before_ng[letter[1]] and ( letter[2] == "nk" or letter[2] == "ng" ) then
					table.insert(IPA, data_m.before_ng[letter[1]])
				else
					table.insert(IPA, data_m.vowels[letter[1]])
				end
				working_string = sub(working_string, 2)
			elseif data_m.internal[letter[1]] then
				table.insert(IPA, data_m.internal[letter[1]])
				working_string = sub(working_string, 2)
			else
				table.insert(IPA, letter[1])
				working_string = sub(working_string, 2)
			end
		end
		IPA = table.concat(IPA)
		for ordering, set_of_rules in ipairs(rules_m) do
			for regex, replacement in pairs(set_of_rules) do
				IPA = gsub(IPA, regex, replacement)
			end
		end
	end
	
	IPA = gsub(IPA, "%-", "")
	
	return IPA
end

function export.convertToIPA(word)
    return export.toIPA("t", word)
end

-- Phonemic
function export.show_M(frame)
	local params = {
		[1] = {},
		[2] = {}
	}
	
	local title = mw.title.getCurrentTitle()
	
	local args = require("Module:parameters").process(frame:getParent().args, params)
	local term = args[1] or title.text
	local accent = args[2]

	local ipa = export.toIPA("m", term, accent)
	
	ipa = "/" .. ipa .. "/"
	ipa = require("Module:IPA").format_IPA_full(require("Module:languages").getByCode("is"), { { pron = ipa } } )

	return ipa
end

-- Phonetic
function export.show_T(frame)
	local params = {
		[1] = {},
		[2] = {}
	}
	
	local title = mw.title.getCurrentTitle()
	
	local args = require("Module:parameters").process(frame:getParent().args, params)
	local term = args[1] or title.text
	local accent = args[2]

	local ipa = export.toIPA("t", term, accent)
	
	ipa = "[" .. ipa .. "]"
	ipa = require("Module:IPA").format_IPA_full(require("Module:languages").getByCode("is"), { { pron = ipa } } )

	return ipa
end

return export