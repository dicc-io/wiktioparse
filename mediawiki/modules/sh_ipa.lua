local export = {}

local m_IPA = require("Module:IPA")
local lang = require("Module:languages").getByCode("sh")

-- single characters that map to IPA sounds
local phonetic_chars_map = {
	["a"] = "a", ["а"] = "a",
	["e"] = "e", ["е"] = "e",
	["i"] = "i", ["и"] = "i",
	["o"] = "o", ["о"] = "o",
	["u"] = "u", ["у"] = "u",
	
	["b"] = "b", ["б"] = "b",
	["v"] = "ʋ", ["в"] = "ʋ",
	["g"] = "ɡ", ["г"] = "ɡ",
	["d"] = "d", ["д"] = "d",
	["đ"] = "d͡ʑ", ["ђ"] = "d͡ʑ",
	["ž"] = "ʒ", ["ж"] = "ʒ",
	["z"] = "z", ["з"] = "z",
	["j"] = "j", ["ј"] = "j",
	["k"] = "k", ["к"] = "k",
	["l"] = "l", ["л"] = "l",
	["љ"] = "ʎ",
	["m"] = "m", ["м"] = "m",
	["n"] = "n", ["н"] = "n",
	["њ"] = "ɲ",
	["p"] = "p", ["п"] = "p",
	["r"] = "r", ["р"] = "r",
	["s"] = "s", ["с"] = "s",
	["t"] = "t", ["т"] = "t",
	["ć"] = "t͡ɕ", ["ћ"] = "t͡ɕ",
	["f"] = "f", ["ф"] = "f",
	["h"] = "x", ["х"] = "x",
	["c"] = "t͡s", ["ц"] = "t͡s",
	["č"] = "t͡ʃ", ["ч"] = "t͡ʃ",
	["џ"] = "d͡ʒ",
	["š"] = "ʃ", ["ш"] = "ʃ",
	
	["ś"] = "ɕ",
	["ź"] = "ʑ",
	["ă"] = "ə", ["ь"] = "ə",
	["ѕ"] = "dz",
	["."] = "",
	["¯"] = "ː",
	["`"] = "ˇ",
	["á"] = "ǎː", ["à"] = "ǎ", ["ā"] = "aː", ["ȁ"] = "â", ["ȃ"] = "âː",
	["é"] = "ěː", ["è"] = "ě", ["ē"] = "eː", ["ȅ"] = "ê", ["ȇ"] = "êː",
	["í"] = "ǐː", ["ì"] = "ǐ", ["ī"] = "iː", ["ȉ"] = "î", ["ȋ"] = "îː",
	["ó"] = "ǒː", ["ò"] = "ǒ", ["ō"] = "oː", ["ȍ"] = "ô", ["ȏ"] = "ôː",
	["ú"] = "ǔː", ["ù"] = "ǔ", ["ū"] = "uː", ["ȕ"] = "û", ["ȗ"] = "ûː",
	["ŕ"] = "ř̩ː", ["ȑ"] = "r̩̂", ["ȓ"] = "r̩̂ː",
	["̏"] = "ˆ",
	["̑"] = "ˆː",
}

-- character sequences of two that map to IPA sounds
local phonetic_2chars_map = {
	["lj"] = "ʎ",
	["nj"] = "ɲ",
	["dž"] = "d͡ʒ",
	["с́"] = "ɕ",
	["з́"] = "ʑ",
	["а́"] = "ǎː", ["а̀"] = "ǎ", ["а̄"] = "aː", ["а̏"] = "â", ["а̑"] = "âː",
	["е́"] = "ěː", ["ѐ"] = "ě", ["е̄"] = "eː", ["е̏"] = "ê", ["е̑"] = "êː",
	["и́"] = "ǐː", ["ѝ"] = "ǐ", ["ӣ"] = "iː", ["и̏"] = "î", ["и̑"] = "îː",
	["о́"] = "ǒː", ["о̀"] = "ǒ", ["о̄"] = "oː", ["о̏"] = "ô", ["о̑"] = "ôː",
	["у́"] = "ǔː", ["у̀"] = "ǔ", ["ӯ"] = "uː", ["у̏"] = "û", ["у̑"] = "ûː",
	["r̀"] = "ř̩", ["r̩̄"] = "r̩ː",
	["р́"] = "ř̩ː", ["р̀"] = "ř̩", ["р̄"] = "r̩ː", ["р̏"] = "r̩̂", ["р̑"] = "r̩̂ː",
}

function export.convertToIPA(word)
	word = mw.ustring.lower(word)

	local phonetic = word

	for pat, repl in pairs(phonetic_2chars_map) do
		phonetic = phonetic:gsub(pat, repl)
	end

	phonetic = mw.ustring.gsub(phonetic, '.', phonetic_chars_map)

	-- assimilation
	phonetic = mw.ustring.gsub(phonetic, "n([ɡk]+)", "ŋ%1")
	phonetic = mw.ustring.gsub(phonetic, "m([fʋ]+)", "ɱ%1")

	-- enable use of an apostrophe to keep letters from forming digraphs, e.g. nad'žívjeti
	phonetic = mw.ustring.gsub(phonetic, "'", "")

	return phonetic
end

function export.show(word)
	if type(word) == "table" then
		word = word.args[1] or word:getParent().args[1]
	end
	if not word or (word == "") then
		error("Please put the word as the first positional parameter!")
	end
	local items = {}
	table.insert(items, {pron = export.to_IPA(word), note = nil})
	return m_IPA.format_IPA_full(lang, items)
end

return export