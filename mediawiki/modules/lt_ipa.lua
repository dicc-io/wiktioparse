local export = {}
local u = mw.ustring.char
local gsub = mw.ustring.gsub
local sub = mw.ustring.sub
local match = mw.ustring.match
local rfind = mw.ustring.find
local ugmatch = mw.ustring.gmatch
local ulen = mw.ustring.len
local function take(term)
	return sub(term, 1, 1), sub(term, 2)
end

local AC = u(0x0301) -- acute =  ́
local GR = u(0x0300) -- grave =  ̀
local TILDE = u(0x0303) -- tilde =  ̃
local BREVE = u(0x0306) -- breve =  ̆
local MACRON = u(0x0304) -- macron =  ̄
local CARON = u(0x030C) -- caron =  ̌
local OGONEK = u(0x0328) -- ogonek =  ̨
local DOT = u(0x0307) -- dot above = ̇

local accents = AC .. GR .. TILDE .. BREVE .. MACRON
local accents_cat = '[' .. accents .. ']'
local diacritics = accents .. CARON .. OGONEK .. DOT
local diacritics_cat = '[' .. diacritics .. ']'
local vowels = 'aeiouy'
local vowels_cat = '[' .. vowels .. ']'
local consonants_no_j = "bcdfghklmnprstvzðþx"
local consonants_no_j_cat = '[' .. consonants_no_j .. ']'
local consonants = consonants_no_j .. "j"
local consonants_cat = '[' .. consonants .. ']'

local lang = require("Module:languages").getByCode("lt")

function export.link(term)
	return require("Module:links").full_link{ term = term, lang = lang }
end


local function orth_to_pron(term)
	--[=[
	This function takes the orthographic representation and makes it closer to
	the phonological output by adding missing segments
	]=]

	-- replace digraph consonants with place holders
	term = gsub(term, "dz", "ð")
	term = gsub(term, "dz" .. CARON, "þ")
	term = gsub(term, "ch", "ç")
	term = gsub(term, "ts", "c")
	term = gsub(term, "o" .. BREVE, "ɔ")
	
	--add missing /j/
	-- ievà > jievà
	if rfind(term, "^i[" .. AC .. GR .. "]?e" .. TILDE .. "?") then
		term = "j" .. term
	end
	-- pãieškos > pãjieškos
	term = gsub(
		term,
		"(" .. vowels_cat .. diacritics_cat .. "*)" .. "(i[" .. AC .. GR .. "]?e" .. TILDE .. "?)",
		"%1j%2"
	)
	
	-- show palatalization
	term = gsub(term, "i([aou]" .. accents_cat .. "*)(.?)",
		function(vow, next_char)
			if next_char == "u" then
				return 'i' .. vow .. next_char
			else
				return "ʲ" .. vow .. next_char
			end
		end
	)
	term = gsub(term, "(" .. consonants_no_j_cat .. CARON .. "?)([iej])", "%1ʲ%2")
	term = gsub(term, "(" .. consonants_no_j_cat .. "+)(" .. consonants_no_j_cat .. "ʲ)",
		function(cons, soft)
			local out = ""
			for c in ugmatch(cons, ".") do
			    out = out .. c .. "ʲ"
			end
			return out .. soft
		end
	)
	
	return term
end

local function syllabify(term)
	term = gsub(
		term,
		"([aeioɔuy" .. AC .. GR .. TILDE .. MACRON .. OGONEK .. DOT ..
		"]*[^aeioɔuy]-)([sz]?" .. CARON .. "?ʲ?[ptkbdðþgçc]?" .. CARON .. "?ʲ?[lmnrvj]?ʲ?[aeioɔuy])",
		"%1.%2"
	)
	term = gsub(term, "^%.", "")
	term = gsub(term, "%.ʲ", "ʲ.")
	term = gsub(term, "%.([ptbdðþ]ʲ?)([mn])", "%1.%2")
	return term
	--[=[local syllables = {}
	local syll = {}
	local char = ""
	
	while ulen(remainder) > 0 do
		char, remainder = take(remainder)
	end
	]=]
end

local function phonemic(term)
	--consonants
	term = gsub(term, "c" .. CARON, "t͡ʃ")
	term = gsub(term, "c", "t͡s")
	term = gsub(term, "ç", "x")
	term = gsub(term, "þ", "d͡ʒ")
	term = gsub(term, "ð", "d͡z")
	term = gsub(term, "g", "ɡ")
	term = gsub(term, "h", "ɣ")
	term = gsub(term, "l$", "ɫ")
	term = gsub(term, "l([^ʲ])", "ɫ%1")
	term = gsub(term, "n(ʲ?.?[kɡ])", "ŋ%1")
	term = gsub(term, "qu", "kv")
	term = gsub(term, "q", "k")
	term = gsub(term, "s" .. CARON, "ʃ")
	term = gsub(term, "z" .. CARON, "ʒ")
	term = gsub(term, "ç", "x")
	term = gsub(term, "ʃʲ", "ɕ")
	term = gsub(term, "ʒʲ", "ʑ")
	
	--vowels
	term = gsub(
		term,
		"^([^%." .. AC .. GR .. TILDE .. "]-[" .. AC .. GR .. TILDE .. "])",
		"ˈ%1"
	)
	term = gsub(
		term,
		"%.([^%." .. AC .. GR .. TILDE .. "]-[" .. AC .. GR .. TILDE .. "])",
		"ˈ%1"
	)
	term = gsub(term, "ia" .. AC .. "u", "æ̂ʊ")
	term = gsub(term, "iau" .. TILDE .. "?", "ɛʊ")
	term = gsub(term, "a" .. AC .. "i", "ɐ̂ɪ")
	term = gsub(term, "ai" .. TILDE .. "?", "ɐɪ")
	term = gsub(term, "e" .. AC .. "i", "ɛ̂ɪ")
	term = gsub(term, "ei" .. TILDE .. "?", "ɛɪ")
	term = gsub(term, "a" .. AC .. "u", "âʊ")
	term = gsub(term, "au" .. TILDE .. "?", "ɒʊ")
	term = gsub(term, "e" .. AC .. "u", "ɛ̂ʊ")
	term = gsub(term, "eu" .. TILDE .. "?", "ɛʊ")
	term = gsub(term, "i" .. AC .. "e", "îə")
	term = gsub(term, "ie" .. TILDE .. "?", "iə")
	term = gsub(term, "u" .. AC .. "o", "ûə")
	term = gsub(term, "uo" .. TILDE .. "?", "uə")
	term = gsub(term, "u" .. AC .. "i", "ʊ̂ɪ")
	term = gsub(term, "ui" .. TILDE .. "?", "ʊɪ")
	term = gsub(term, "o" .. AC .. "u", "ɔ̂ɪ")
	term = gsub(term, "u" .. AC .. "u", "ɔ̂ʊ")

	term = gsub(term, "a", "ɐ")
	term = gsub(term, "ɐ" .. AC, "âː")
	term = gsub(term, "ɐ" .. TILDE, "aː")

	term = gsub(term, "e", "ɛ")
	term = gsub(term, "ɛ" .. DOT, "eː")
	term = gsub(term, "ɛ" .. OGONEK, "æː")

	term = gsub(term, "i", "ɪ")
	term = gsub(term, "ɪ" .. OGONEK, "iː")

	term = gsub(term, "y", "iː")

	term = gsub(term, "u", "ʊ")
	term = gsub(term, "ʊ" .. MACRON, "uː")
	term = gsub(term, "ʊ" .. OGONEK, "uː")

	term = gsub(term, "o" .. TILDE .. "?", "oː")

	term = gsub(term, "ː" .. AC, "̂ː") -- acutes = stressed + circumflex tone
	term = gsub(term, TILDE, "") -- tilde = stressed + long
	term = gsub(term, GR, "") -- grave = stressed + short
	
	term = gsub(term, "([ʲj])a(" .. OGONEK .. "?)", "%1e%2")
	return term
end

function export.convertToIPA(text)
	local syll = syllabify(orth_to_pron(mw.ustring.toNFD(text)))

	return phonemic(syll)
end

function export.test_orth_to_pron(frame)
	local args = require("Module:parameters").process(frame:getParent().args, {[1] = {default = ""}})
	
	local syll = syllabify(orth_to_pron(mw.ustring.toNFD(args[1])))

	return syll .. '→ /' .. phonemic(syll) .. '/'
end

function export.show(frame)
	local params = {
		[1] = {default = mw.title.getCurrentTitle().text}
	}
	
	local args = require("Module:parameters").process(frame:getParent().args, params)
	
	local term = mw.ustring.lower(args[1])
	
	return term
end

return export