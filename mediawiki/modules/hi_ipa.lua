local export = {}

local lang = require("Module:languages").getByCode("hi")
local sc = require("Module:scripts").getByCode("Deva")
local m_IPA = require("Module:IPA")

local gsub = mw.ustring.gsub
local gmatch = mw.ustring.gmatch
local find = mw.ustring.find

local correspondences = {
	["ṅ"] = "ŋ", ["g"] = "ɡ", 
	["c"] = "t͡ʃ", ["j"] = "d͡ʒ", ["ñ"] = "n",
	["ṭ"] = "ʈ", ["ḍ"] = "ɖ", ["ṇ"] = "ɳ",
	["t"] = "t̪", ["d"] = "d̪",
	["y"] = "j", ["r"] = "ɾ", ["v"] = "ʋ", ["l"] = "l̪",
	["ś"] = "ʃ", ["ṣ"] = "ʂ", ["h"] = "ɦ",
	["ṛ"] = "ɽ", ["ž"] = "ʒ", ["ḻ"] = "ɭ", ["ġ"] = "ɣ", ["q"] = "q", ["x"] = "x", ["ṉ"] = "n", ["ṟ"] = "r",

	["a"] = "ə", ["ā"] = "ɑː", ["i"] = "ɪ",
	["ī"] = "iː", ["ō"] = "oː", ["ē"] = "eː",
	["u"] = "ʊ", ["ū"] = "uː", ["ô"] = "ɔ", ["ê"] = "æ",

	["ē̃"] = "ẽː", ["ũ"] = "ʊ̃", ["ō̃"] = "õː", ["ã"] = "ə̃", ["ā̃"] = "ɑ̃ː",  ["ĩ"] = "ɪ̃", ["ī̃"] = "ĩː",

	["ॐ"] = "oːm", ["ḥ"] = "ʰ", ["'"] = "(ʔ)",
}

local perso_arabic = {
	["x"] = "kh", ["ġ"] = "g", ["q"] = "k", ["ž"] = "z", ["z"] = "j", ["f"] = "ph", ["'"] = "",
}

local lengthen = {
	["a"] = "ā", ["i"] = "ī", ["u"] = "ū",
}

local vowels = "aāiīuūōôêʊɪɔɔ̃ɛēæãā̃ē̃ĩī̃ō̃ũū̃ː"
local vowel = "[aāiīuūōôêʊɪɔɔ̃ɛēæãā̃ē̃ĩī̃ō̃ũū̃]ː?"
local weak_h = "([gjdḍbṛnm])h"
local aspirate = "([kctṭp])"
local syllabify_pattern = "([" .. vowels .. "]̃?)([^" .. vowels .. "%.%-]+)([" .. vowels .. "]̃?)"

local function find_consonants(text)
	local current = ""
	local cons = {}
	for cc in mw.ustring.gcodepoint(text .. " ") do
		local ch = mw.ustring.char(cc)
		if find(current .. ch, "^[kgṅcjñṭḍṇtdnpbmyrlvśṣshqxġzžḻṛṟfθṉḥ]$") or find(current .. ch, "^[kgcjṭḍṇtdpbṛ]h$") then
			current = current .. ch
		else
			table.insert(cons, current)
			current = ch
		end
	end
	return cons
end

local function syllabify(text)
	for count = 1, 2 do
		text = gsub(text, syllabify_pattern, function(a, b, c)
			b_set = find_consonants(b)
			table.insert(b_set, #b_set > 1 and 2 or 1, ".")
			return a .. table.concat(b_set) .. c
			end)
		text = gsub(text, "(" .. vowel .. ")(?=" .. vowel .. ")", "%1.")
	end
	for count = 1, 2 do
		text = gsub(text, "(" .. vowel .. ")(" .. vowel .. ")", "%1.%2")
	end
	return text
end

local identical = "knlsfzθ"
for character in gmatch(identical, ".") do
	correspondences[character] = character
end

local function transliterate(text)
	return lang:transliterate(text)
end

function export.link(term)
	return require("Module:links").full_link{ term = term, lang = lang, sc = sc }
end

function export.narrow_IPA(ipa)
	-- what /ɑ/ really is
	ipa = gsub(ipa, 'ɑ', 'ä')
	-- dentals
	ipa = gsub(ipa, '([snl])', '%1̪')
	-- nasals induce nasalization
	ipa = gsub(ipa, '([əäɪiʊueɛoɔæ])(ː?)([nɳŋm])', '%1̃%2%3')
	-- cc, jj
	ipa = gsub(ipa, 't͡ʃ(%.?)t͡ʃ', 't̚%1t͡ʃ')
	ipa = gsub(ipa, 'd͡ʒ(%.?)d͡ʒ', 'd̚%1d͡ʒ')
	-- syllable boundary consonants
	ipa = gsub(ipa, '([kg])%.([kg])', '%1̚.%2')
	ipa = gsub(ipa, '([ʈɖ])%.([ʈɖ])', '%1̚.%2')
	ipa = gsub(ipa, '([td]̪?)%.([tdn])', '%1̚.%2')
	ipa = gsub(ipa, '([pb])%.([pb])', '%1̚.%2')
	-- aspiration rules
	ipa = gsub(ipa, 'əɦ%.([kgŋtdɲʈɖɳnpbmɾlzqfʂʃsʒɭɣɹʋj])', 'ɛɦ.%1')
	ipa = gsub(ipa, 'ʊɦ%.([kgŋtdɲʈɖɳnpbmɾlzqfʂʃsʒɭɣɹʋj])', 'ɔɦ.%1')
	ipa = gsub(ipa, 'ə%.ɦə', 'ɛ.ɦɛ')
	ipa = gsub(ipa, 'ʊ%.ɦə', 'ɔ.ɦɔ')
	ipa = gsub(ipa, 'ə%.ɦʊ', 'ɔ.ɦɔ')
	-- v/w
	ipa = gsub(ipa, '([kgŋtdɲʈɖɳnpbm]̪?%.?)ʋ', '%1w')
	-- retroflex s rules
	ipa = gsub(ipa, 'ʂ(%.?[^ʈɖ])', 'ʃ%1')
        ipa = gsub(ipa, '([ŋn])%.([q])', 'ɴ.%2')
	ipa = gsub(ipa, 'ʂ$', 'ʃ')
	ipa = gsub(ipa, "ɪ%.j", "i.j")
	return ipa
end

function export.convertToIPA(text, style)
	text = gsub(text, '॰', '-')
	local translit = transliterate(text)
	if not translit then
		error('The term "' .. Hindi .. '" could not be transliterated.')
	end

	-- persian consonant substitution
	translit = gsub(translit, 'k͟h', 'x')
	translit = gsub(translit, 's̱', 'θ')
	
	if style == "nonpersianized" then
		translit = gsub(translit, "[xġqžzf']", perso_arabic)
	end
	
	-- force final schwa
	translit = gsub(translit, "a~$", "ə")
	
	-- vowels
	translit = gsub(translit, "͠", "̃")
	translit = gsub(translit, 'a(̃?)i', 'ɛ%1ː')
	translit = gsub(translit, 'a(̃?)u', 'ɔ%1ː')
	translit = gsub(translit, "%-$", "")
	translit = gsub(translit, "^%-", "")
	translit = gsub(translit, "r̥$", "r")
	translit = gsub(translit, "r̥", "ri")
	translit = gsub(translit, ",", "")
	translit = gsub(translit, " ", "..")
	
	translit = syllabify(translit)
	translit = gsub(translit, "%.ː", "ː.")
	translit = gsub(translit, "%.̃", "̃")
	
	-- gy
	translit = gsub(translit, 'jñ', 'gy')


	translit = gsub(translit, aspirate .. "h", '%1ʰ')
	translit = gsub(translit, weak_h, '%1ʱ')
	
	local result = gsub(translit, ".", correspondences)

	-- remove final schwa (Pandey, 2014)
	-- actually weaken
	result = gsub(result, "(...)ə$", "%1ᵊ")
	result = gsub(result, "(...)ə ", "%1ᵊ ")
	result = gsub(result, "(...)ə%.?%-", "%1ᵊ-")
	result = gsub(result, "%.?%-", ".")

	result = gsub(result, "%.%.", "‿")
	
	-- formatting
	result = gsub(result, "ː̃", "̃ː")
	result = gsub(result, "ː%.̃", "̃ː.")
	result = gsub(result, "%.$", "")

	-- i and u lengthening
	result = gsub(result, "ʊ(̃?)(ʱ?)$", "u%1ː%2")
	result = gsub(result, "ɪ(̃?)(ʱ?)$", "i%1ː%2")
	
	result = gsub(result, "ɛː(%.?)j", function(a)
		local res = "ə̯i"
		res = res .. a .. "j"
		return res
	end)
	result = gsub(result, "ɔː(%.?)ʋ", function(a)
		local res = "ə̯u"
		res = res .. a .. "ʋ"
		return res
	end)
	
	return result
end

function export.make(frame)
	local args = frame:getParent().args
	local pagetitle = mw.title.getCurrentTitle().text
	
	local p, results = {}, {}, {}
	
	if args[1] then
		for index, item in ipairs(args) do
			table.insert(p, (item ~= "") and item or nil)
		end
	else
		p = { pagetitle }
	end
	
	for _, Hindi in ipairs(p) do
		local nonpersianized = export.toIPA(Hindi, "nonpersianized")
		local persianized = export.toIPA(Hindi, "persianized")
		table.insert(results, { pron = "/" .. nonpersianized .. "/" })
		local narrow = export.narrow_IPA(nonpersianized)
		if narrow ~= nonpersianized then table.insert(results, { pron = "[" .. narrow .. "]" }) end
		if nonpersianized ~= persianized then
			table.insert(results, { pron = "/" .. persianized .. "/" })
			local narrow = export.narrow_IPA(persianized)
			if narrow ~= persianized then table.insert(results, { pron = "[" .. narrow .. "]" }) end
		end
	end
	
	return  m_IPA.format_IPA_full(lang, results)
end

function export.make_ur(frame)
	local args = frame:getParent().args
	local pagetitle = mw.title.getCurrentTitle().text
	local lang = require("Module:languages").getByCode("ur")
	local sc = require("Module:scripts").getByCode("ur-Arab")
	
	local p, results = {}, {}, {}
	
	if args[1] then
		for index, item in ipairs(args) do
			table.insert(p, (item ~= "") and item or nil)
		end
	else
		error("No transliterations given.")
	end
	
	for _, Urdu in ipairs(p) do
		table.insert(results, { pron = "/" .. export.toIPA(Urdu, "persianized") .. "/" })
	end
	
	return  m_IPA.format_IPA_full(lang, results)
end

return export