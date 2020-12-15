local export = {}

local find = mw.ustring.find
local gsub = mw.ustring.gsub
local len = mw.ustring.len
local match = mw.ustring.match
local sub = mw.ustring.sub
local split = mw.text.split
local gsplit = mw.text.gsplit

local m_zh = require("Module:zh")
local _m_zh_data = nil
local hom_data = mw.loadData("Module:zh/data/cmn-hom")

-- if not empty
local function ine(var)
	if var == "" then
		return nil
	else
		return var
	end
end

local breve, hacek = mw.ustring.char(0x306), mw.ustring.char(0x30C)
local decompose = mw.ustring.toNFD
local function breve_error(text)
	if type(text) ~= "string" then
		return
	end
	text = decompose(text)
	if text:find(breve) then
		error('The pinyin text "' .. text .. '" contains a breve. Replace it with "' .. text:gsub(breve, hacek) .. '".', 2)
	end
end

local function m_zh_data()
	if _m_zh_data == nil then _m_zh_data = mw.loadData("Module:zh/data/cmn-tag") end;
	return _m_zh_data;
end

local py_detone = {
	['ā'] = 'a', ['á'] = 'a', ['ǎ'] = 'a', ['à'] = 'a', 
	['ō'] = 'o', ['ó'] = 'o', ['ǒ'] = 'o', ['ò'] = 'o', 
	['ē'] = 'e', ['é'] = 'e', ['ě'] = 'e', ['è'] = 'e',
	['ê̄'] = 'ê', ['ế'] = 'ê', ['ê̌'] = 'ê', ['ề'] = 'ê',
	['ī'] = 'i', ['í'] = 'i', ['ǐ'] = 'i', ['ì'] = 'i', 
	['ū'] = 'u', ['ú'] = 'u', ['ǔ'] = 'u', ['ù'] = 'u', 
	['ǖ'] = 'ü', ['ǘ'] = 'ü', ['ǚ'] = 'ü', ['ǜ'] = 'ü',
	['m̄'] = 'm', ['ḿ'] = 'm', ['m̌'] = 'm', ['m̀'] = 'm',
	['n̄'] = 'n', ['ń'] = 'n', ['ň'] = 'n', ['ǹ'] = 'n',
}

local py_tone = {
	['̄'] = '1',
	['́'] = '2',
	['̌'] = '3',
	['̀'] = '4'
}

local tones = '[̄́̌̀]'

function export.py_detone(f)
	local text = type(f) == 'table' and f.args[1] or f
	return mw.ustring.toNFC(gsub(mw.ustring.toNFD(text), tones, ''))
end

function export.py_transf(f)
	local text = type(f) == 'table' and f.args[1] or f
	return export.py_detone(text) .. export.tone_determ(text)
end

function export.tone_determ(f)
	local text = type(f) == 'table' and f.args[1] or f
	text = mw.ustring.toNFD(text)
	return py_tone[match(text, tones)] or '5'
end

function export.py_transform(text, detone, not_spaced)
	if type(text) == 'table' then text, detone, not_spaced = text.args[1], text.args[2], text.args[3] end
	if find(text, '​') then
		error("Pinyin contains the hidden character: ​ (U+200B). Please remove that character from the text.")
	end
	detone = ine(detone)
	not_spaced = ine(not_spaced)
	text = gsub(gsub(mw.ustring.toNFD(text), mw.ustring.toNFD('ê'), 'ê'), mw.ustring.toNFD('ü'), 'ü')
	if find(mw.ustring.lower(text), '[aeiouêü]' .. tones .. '[aeiou]?[aeiouêü]' .. tones .. '') and not not_spaced then
		error(("Missing apostrophe before null-initial syllable - should be \"%s\" instead."):format(gsub(text, '([aeiouêü]' .. tones .. '[aeiou]?)([aeiouêü]' .. tones .. ')', "%1'%2"))) end
	original_text = text
	text = gsub(text,'([aoeAOE])([iou])(' .. tones .. ')', '%1%3%2')
	text = gsub(text,'([iuü])(' .. tones .. ')([aeiou])', '%1%3%2')
	if text ~= original_text then
		error("Incorrect diacritic placement in Pinyin - should be \"".. text .. "\" instead.") end
	text = mw.ustring.lower(text)
	if not mw.ustring.find(text, tones) and text:find('[1-5]') then
		return gsub(text, '(%d)(%l)', '%1 %2')
	end
	text = gsub(text, "#", " #")
	if find(text, '[一不,.?]') then
		text = gsub(text, '([一不])$', {['一'] = ' yī', ['不'] = ' bù'})
		text = gsub(text, '([一不])', ' %1 ')
		text = gsub(text, '([,.?])', ' %1 ')
		text = gsub(text, ' +', ' ')
		text = gsub(text, '^ ', '')
		text = gsub(text, ' $', '')
		text = gsub(text, '%. %. %.', '...')
	end
	text = gsub(text, "['%-]", ' ')
	text = gsub(text, '([aeiouêümn]' .. tones .. '?n?g?r?)([bpmfdtnlgkhjqxzcsywr]h?)', '%1 %2')
	text = gsub(text, ' ([grn])$', '%1')
	text = gsub(text, ' ([grn]) ', '%1 ')
	if detone then
		text = mw.ustring.gsub(text, tones, py_tone)
		text = gsub(text, '([1234])([^ ]*)', '%2%1')
		text = mw.ustring.gsub(text, '([%lüê]) ', '%15 ')
		text = mw.ustring.gsub(text, '([%lüê])$', '%15')
	end
	if not_spaced then
		text = gsub(text, ' ', '')
	end
	return mw.ustring.toNFC(text)
end

function export.convertToIPA(text)
	local ipa_initial = {
		['b'] = 'p', ['p'] = 'pʰ', ['m'] = 'm', ['f'] = 'f', 
		['d'] = 't', ['t'] = 'tʰ', ['n'] = 'n', ['l'] = 'l', 
		['g'] = 'k', ['k'] = 'kʰ', ['h'] = 'x', ['ng'] = 'ŋ', 
		['j'] = 't͡ɕ', ['q'] = 't͡ɕʰ', ['x'] = 'ɕ', 
		['z'] = 't͡s', ['c'] = 't͡sʰ', ['s'] = 's', ['r'] = 'ʐ', 
		['zh'] = 'ʈ͡ʂ', ['ch'] = 'ʈ͡ʂʰ', ['sh'] = 'ʂ', 
		[''] = ''
	}

	local ipa_initial_tl = {
		['p'] = 'b̥', ['t'] = 'd̥', ['k'] = 'g̊', ['t͡ɕ'] = 'd͡ʑ̥', ['t͡s'] = 'd͡z̥', ['ʈ͡ʂ'] = 'ɖ͡ʐ̥'
	}

	local ipa_final = {
		['yuanr'] = 'ɥɑɻ', ['iangr'] = 'jɑ̃ɻ', ['yangr'] = 'jɑ̃ɻ', ['uangr'] = 'wɑ̃ɻ', ['wangr'] = 'wɑ̃ɻ', ['yingr'] = 'iɤ̯̃ɻ', ['wengr'] = 'ʊ̃ɻ', ['iongr'] = 'jʊ̃ɻ', ['yongr'] = 'jʊ̃ɻ', 
		['yuan'] = 'ɥɛn', ['iang'] = 'jɑŋ', ['yang'] = 'jɑŋ', ['uang'] = 'wɑŋ', ['wang'] = 'wɑŋ', ['ying'] = 'iŋ', ['weng'] = 'wəŋ', ['iong'] = 'jʊŋ', ['yong'] = 'jʊŋ', ['ianr'] = 'jɑɻ', ['yanr'] = 'jɑɻ', ['uair'] = 'wɑɻ', ['wair'] = 'wɑɻ', ['uanr'] = 'wɑɻ', ['wanr'] = 'wɑɻ', ['iaor'] = 'jaʊ̯ɻʷ', ['yaor'] = 'jaʊ̯ɻʷ', ['üanr'] = 'ɥɑɻ', ['vanr'] = 'ɥɑɻ', ['angr'] = 'ɑ̃ɻ', ['yuer'] = 'ɥɛɻ', ['weir'] = 'wəɻ', ['wenr'] = 'wəɻ', ['your'] = 'jɤʊ̯ɻʷ', ['yinr'] = 'iə̯ɻ', ['yunr'] = 'yə̯ɻ', ['engr'] = 'ɤ̃ɻ', ['ingr'] = 'iɤ̯̃ɻ', ['ongr'] = 'ʊ̃ɻ', 
		['uai'] = 'waɪ̯', ['wai'] = 'waɪ̯', ['yai'] = 'jaɪ̯', ['iao'] = 'jɑʊ̯', ['yao'] = 'jɑʊ̯', ['ian'] = 'jɛn', ['yan'] = 'jɛn', ['uan'] = 'wän', ['wan'] = 'wän', ['üan'] = 'ɥɛn', ['van'] = 'ɥɛn', ['ang'] = 'ɑŋ', ['yue'] = 'ɥɛ', ['wei'] = 'weɪ̯', ['you'] = 'joʊ̯', ['yin'] = 'in', ['wen'] = 'wən', ['yun'] = 'yn', ['eng'] = 'ɤŋ', ['ing'] = 'iŋ', ['ong'] = 'ʊŋ', ['air'] = 'ɑɻ', ['anr'] = 'ɑɻ', ['iar'] = 'jɑɻ', ['yar'] = 'jɑɻ', ['uar'] = 'wɑɻ', ['war'] = 'wɑɻ', ['aor'] = 'aʊ̯ɻʷ', ['ier'] = 'jɛɻ', ['yer'] = 'jɛɻ', ['uor'] = 'wɔɻ', ['wor'] = 'wɔɻ', ['üer'] = 'ɥɛɻ', ['ver'] = 'ɥɛɻ', ['eir'] = 'əɻ', ['enr'] = 'əɻ', ['uir'] = 'wəɻ', ['unr'] = 'wəɻ', ['our'] = 'ɤʊ̯ɻʷ', ['iur'] = 'jɤʊ̯ɻʷ', ['inr'] = 'iə̯ɻ', ['ünr'] = 'yə̯ɻ', ['vnr'] = 'yə̯ɻ', ['yir'] = 'iə̯ɻ', ['wur'] = 'uɻʷ', ['yur'] = 'yə̯ɻ', ['yor'] = 'jɔɻ', 
		['yo'] = 'jɔ', ['ia'] = 'jä', ['ya'] = 'jä', ['ua'] = 'wä', ['wa'] = 'wä', ['ai'] = 'aɪ̯', ['ao'] = 'ɑʊ̯', ['an'] = 'än', ['ie'] = 'jɛ', ['ye'] = 'jɛ', ['uo'] = 'wɔ', ['wo'] = 'wɔ', ['ue'] = 'ɥɛ', ['üe'] = 'ɥɛ', ['ve'] = 'ɥɛ', ['ei'] = 'eɪ̯', ['ui'] = 'weɪ̯', ['ou'] = 'oʊ̯', ['iu'] = 'joʊ̯', ['en'] = 'ən', ['in'] = 'in', ['un'] = 'wən', ['ün'] = 'yn', ['vn'] = 'yn', ['yi'] = 'i', ['wu'] = 'u', ['yu'] = 'y', ['mˋ'] = 'm̩', ['ng'] = 'ŋ̍', ['ňg'] = 'ŋ̍', ['ńg'] = 'ŋ̍', ['ê̄'] = 'ɛ', ['ê̌'] = 'ɛ', ['ar'] = 'ɑɻ', ['er'] = 'ɤɻ', ['or'] = 'wɔɻ', ['ir'] = 'iə̯ɻ', ['ur'] = 'uɻʷ', ['ür'] = 'yə̯ɻ', ['vr'] = 'yə̯ɻ', 
		['a'] = 'ä', ['e'] = 'ɤ', ['o'] = 'wɔ', ['i'] = 'i', ['u'] = 'u', ['ü'] = 'y', ['v'] = 'y', ['m'] = 'm̩', ['ḿ'] = 'm̩', ['n'] = 'n̩', ['ń'] = 'n̩', ['ň'] = 'n̩', ['ê'] = 'ɛ'
	}

	local ipa_null = {
		['a'] = true, ['o'] = true, ['e'] = true, ['ê'] = true,
		['ai'] = true, ['ei'] = true, ['ao'] = true, ['ou'] = true,
		['an'] = true, ['en'] = true, ['er'] = true, 
		['ang'] = true, ['ong'] = true, ['eng'] = true,
	}

	local ipa_tl_ts = {
		['1'] = '²', ['2'] = '³', ['3'] = '⁴', ['4'] = '¹', ['5'] = '¹'
	}

	local ipa_third_t_ts = {
		['1'] = '²¹⁴⁻²¹¹', ['3'] = '²¹⁴⁻³⁵', ['#3'] = '²¹⁴⁻²¹¹', ['5'] = '²¹⁴', ['2'] = '²¹⁴⁻²¹¹', ['1-2'] = '²¹⁴⁻²¹¹', ['4-2'] = '²¹⁴⁻²¹¹', ['4'] = '²¹⁴⁻²¹¹', ['1-4'] = '²¹⁴⁻²¹¹'
	}

	local ipa_t_values = {
		['4'] = '⁵¹', ['1-4'] = '⁵⁵⁻⁵¹', ['1'] = '⁵⁵', ['2'] = '³⁵', ['1-2'] = '⁵⁵⁻³⁵', ['4-2'] = '⁵¹⁻³⁵'
	}

	local tone = {}
	local tone_cat = {}
	text = gsub(export.py_transform(text), '[,.]', '')
	text = gsub(text, ' +', ' ')
	local p = split(text, " ")
	
	for i = 1, #p do
		tone_cat[i] = export.tone_determ(p[i])
		p[i] = gsub(p[i], '.[̄́̌̀]?', py_detone)

		if p[i] == '一' then
			tone_cat[i] = (export.tone_determ(p[i+1]) == '4' or p[i+1] == 'ge') and '1-2' or '1-4'
			p[i] = 'yi'
		elseif p[i] == '不' then
			tone_cat[i] = (export.tone_determ(p[i+1]) == '4') and '4-2' or '4'
			p[i] = 'bu'
		end
	end
	
	tone_cat.length = #tone_cat
	
	local function get_initial_and_final_IPA(a, b, c)
		return a ..
		(ipa_initial[b] or error(("Unrecognised initial: \"%s\""):format(b))) .. 
		(ipa_final[c] or error(("Unrecognised final: \"%s\". Are you missing an apostrophe before the null-initial syllable, or using an invalid Pinyin final?"):format(c)))
	end

	for i, item in ipairs(p) do
		if ipa_null[item] then item = 'ˀ' .. item end
		item = gsub(item, '([jqx])u', '%1ü')

		if item == 'ng' then
			item = ipa_final['ng']
		else
			item = gsub(item, '^(#?ˀ?)([bcdfghjklmnpqrstxz]?h?)(.+)$', 
				get_initial_and_final_IPA)
		end
		
		item = gsub(item, '(ʈ?͡?[ʂʐ]ʰ?)ir', '%1ʐ̩ɻ')
		item = gsub(item, '(ʈ?͡?[ʂʐ]ʰ?)i', '%1ʐ̩')
		item = gsub(item, '(t?͡?sʰ?)ir', '%1z̩ɻ')
		item = gsub(item, '(t?͡?sʰ?)i', '%1z̩')
		item = gsub(item, 'ʐʐ̩', 'ʐ̩')
		item = gsub(item, 'ˀwɔ', 'ˀɔ')
		
		local curr_tone_cat, next_tone_cat = tone_cat[i], tone_cat[i+1]

		if curr_tone_cat == '5' then
			item = gsub(item, '^([ptk])([^͡ʰ])', function(a, b) return ipa_initial_tl[a] .. b end)
			item = gsub(item, '^([tʈ]͡[sɕʂ])([^ʰ])', function(a, b) return ipa_initial_tl[a] .. b end)
			item = gsub(item, 'ɤ$', 'ə')
			tone[i] = ipa_tl_ts[tone_cat[i-1]] or ""

		elseif curr_tone_cat == '3' then
			if p[i+1] and match(p[i+1], "#") then next_tone_cat = "#3" end
			if i == tone_cat.length then
				if i == 1 then tone[i] = '²¹⁴' else tone[i] = '²¹⁴⁻²¹⁽⁴⁾' end
			else
				tone[i] = ipa_third_t_ts[next_tone_cat]
			end

		elseif curr_tone_cat == '4' and next_tone_cat == '4' then
			tone[i] = '⁵¹⁻⁵³'

		elseif curr_tone_cat == '4' and next_tone_cat == '1-4' then
			tone[i] = '⁵¹⁻⁵³'

		elseif curr_tone_cat == '1-4' and next_tone_cat == '4' then
			tone[i] = '⁵⁵⁻⁵³'

		else
			tone[i] = ipa_t_values[curr_tone_cat]
		end
		p[i] = item .. tone[i]
		p[i] = gsub(p[i], "#", "")
	end
	return table.concat(p, " ")
end

function export.py_number_to_mark(text)
	local priority = { "a", "o", "e", "ê", "i", "u", "ü" }
	local toneMark = { ["1"] = "̄", ["2"] = "́", ["3"] = "̌", ["4"] = "̀", ["5"] = "", ["0"] = "", [""] = "" }
	
	local mark = toneMark[match(text, "[0-5]?$")]
	local toneChars = "[̄́̌̀]"
	text = gsub(text, "[0-5]?$", "")
	
	for _, letter in ipairs(priority) do
		text = gsub(text, letter, letter .. mark)
		if find(text, toneChars) then break end
	end
	return mw.ustring.toNFC(gsub(text, "i("..toneChars..")u", "iu%1"))
end

function export.py_zhuyin(text)
	local zhuyin_initial = {
		['b'] = 'ㄅ', ['p'] = 'ㄆ', ['m'] = 'ㄇ', ['f'] = 'ㄈ', 
		['d'] = 'ㄉ', ['t'] = 'ㄊ', ['n'] = 'ㄋ', ['l'] = 'ㄌ', 
		['g'] = 'ㄍ', ['k'] = 'ㄎ', ['h'] = 'ㄏ', 
		['j'] = 'ㄐ', ['q'] = 'ㄑ', ['x'] = 'ㄒ', 
		['z'] = 'ㄗ', ['c'] = 'ㄘ', ['s'] = 'ㄙ', ['r'] = 'ㄖ', 
		['zh'] = 'ㄓ', ['ch'] = 'ㄔ', ['sh'] = 'ㄕ', 
		[''] = ''
	}

	local zhuyin_final = {
		['yuan'] = 'ㄩㄢ', ['iang'] = 'ㄧㄤ', ['yang'] = 'ㄧㄤ', ['uang'] = 'ㄨㄤ', ['wang'] = 'ㄨㄤ', ['ying'] = 'ㄧㄥ', ['weng'] = 'ㄨㄥ', ['iong'] = 'ㄩㄥ', ['yong'] = 'ㄩㄥ', 
		['uai'] = 'ㄨㄞ', ['wai'] = 'ㄨㄞ', ['yai'] = 'ㄧㄞ', ['iao'] = 'ㄧㄠ', ['yao'] = 'ㄧㄠ', ['ian'] = 'ㄧㄢ', ['yan'] = 'ㄧㄢ', ['uan'] = 'ㄨㄢ', ['wan'] = 'ㄨㄢ', ['üan'] = 'ㄩㄢ', ['ang'] = 'ㄤ', ['yue'] = 'ㄩㄝ', ['wei'] = 'ㄨㄟ', ['you'] = 'ㄧㄡ', ['yin'] = 'ㄧㄣ', ['wen'] = 'ㄨㄣ', ['yun'] = 'ㄩㄣ', ['eng'] = 'ㄥ', ['ing'] = 'ㄧㄥ', ['ong'] = 'ㄨㄥ', 
		['yo'] = 'ㄧㄛ', ['ia'] = 'ㄧㄚ', ['ya'] = 'ㄧㄚ', ['ua'] = 'ㄨㄚ', ['wa'] = 'ㄨㄚ', ['ai'] = 'ㄞ', ['ao'] = 'ㄠ', ['an'] = 'ㄢ', ['ie'] = 'ㄧㄝ', ['ye'] = 'ㄧㄝ', ['uo'] = 'ㄨㄛ', ['wo'] = 'ㄨㄛ', ['ue'] = 'ㄩㄝ', ['üe'] = 'ㄩㄝ', ['ei'] = 'ㄟ', ['ui'] = 'ㄨㄟ', ['ou'] = 'ㄡ', ['iu'] = 'ㄧㄡ', ['en'] = 'ㄣ', ['in'] = 'ㄧㄣ', ['un'] = 'ㄨㄣ', ['ün'] = 'ㄩㄣ', ['yi'] = 'ㄧ', ['wu'] = 'ㄨ', ['yu'] = 'ㄩ', 
		['a'] = 'ㄚ', ['e'] = 'ㄜ', ['o'] = 'ㄛ', ['i'] = 'ㄧ', ['u'] = 'ㄨ', ['ü'] = 'ㄩ', ['ê'] = 'ㄝ', [''] = ''
	}

	local zhuyin_er = {
		['r'] = 'ㄦ', [''] = ''
	}
	
	local zhuyin_tone = {
		['1'] = '', ['2'] = 'ˊ', ['3'] = 'ˇ', ['4'] = 'ˋ', ['5'] = '˙', ['0'] = '˙'
	}
	
	if type(text) == 'table' then
		if text.args[1] == '' then
			text = mw.title.getCurrentTitle().text
		else
			text = text.args[1]
		end
	end
	breve_error(text)
	text = gsub(text, "#", "")
	text = export.py_transform(text, true)
	text = gsub(text, '([jqx])u', '%1ü')
	text = gsub(text, '([zcs]h?)i', '%1')
	text = gsub(text, '([r])i', '%1')
	
	local function add_tone(syllable, tone)
		if tone == '5' then
			return zhuyin_tone[tone] .. syllable
		else
			return syllable .. zhuyin_tone[tone]
		end
	end
	local function fun1(a, b) return add_tone((({['ng'] = 'ㄫ', ['hm'] = 'ㄏㄇ'})[a] or a), b) end
	local function fun2(number) return add_tone('ㄏㄫ', number) end
	local function fun3(number) return add_tone('ㄦ', number) end
	local function fun4(a, b, c, d) return add_tone(zhuyin_initial[a] .. zhuyin_final[b], d) .. zhuyin_er[c] end
	
	local word = split(text, " ", true)
	for i, syllable in ipairs(word) do
		if find(syllable, '^[hn][mg][012345]$') then
			syllable = gsub(syllable, '^([hn][mg])([012345])$', fun1)
		elseif find(syllable, '^hng[012345]$') then
			syllable = gsub(syllable, '^hng([012345])$', fun2)
		elseif find(syllable, '^er[012345]$') then
			syllable = gsub(syllable, '^er([012345])$', fun3)
		else
			syllable = gsub(syllable, '^([bpmfdtnlgkhjqxzcsr]?h?)([aeiouêüyw]?[aeioun]?[aeioung]?[ng]?)(r?)([012345])$', 
				fun4)
		end
		if find(syllable, '[%l%d]') then
			error(("Zhuyin conversion unsuccessful: \"%s\". Are you using a valid Pinyin syllable? Is the text using a breve letter instead of a caron one?"):format(syllable))
		end
		word[i] = syllable
	end
	text = gsub(table.concat(word, " "), ' , ', ', ')
	return text
end

function export.zhuyin_py(text)
	local zhuyin_py_initial = {
		["ㄅ"] = "b", ["ㄆ"] = "p", ["ㄇ"] = "m", ["ㄈ"] = "f", 
		["ㄉ"] = "d", ["ㄊ"] = "t", ["ㄋ"] = "n", ["ㄌ"] = "l", 
		["ㄍ"] = "g", ["ㄎ"] = "k", ["ㄏ"] = "h", 
		["ㄐ"] = "j", ["ㄑ"] = "q", ["ㄒ"] = "x", 
		["ㄓ"] = "zh", ["ㄔ"] = "ch", ["ㄕ"] = "sh", ["ㄖ"] = "r", 
		["ㄗ"] = "z", ["ㄘ"] = "c", ["ㄙ"] = "s", 
		[""] = ""
	}

	local zhuyin_py_final = {
		['ㄚ'] = 'a', ['ㄛ'] = 'o', ['ㄜ'] = 'e', ['ㄝ'] = 'ê', ['ㄞ'] = 'ai', ['ㄟ'] = 'ei', ['ㄠ'] = 'ao', ['ㄡ'] = 'ou', ['ㄢ'] = 'an', ['ㄣ'] = 'en', ['ㄤ'] = 'ang', ['ㄥ'] = 'eng', 
		['ㄧ'] = 'i', ['ㄧㄚ'] = 'ia', ['ㄧㄛ'] = 'io', ['ㄧㄝ'] = 'ie', ['ㄧㄞ'] = 'iai', ['ㄧㄠ'] = 'iao', ['ㄧㄡ'] = 'iu', ['ㄧㄢ'] = 'ian', ['ㄧㄣ'] = 'in', ['ㄧㄤ'] = 'iang', ['ㄧㄥ'] = 'ing', 
		['ㄨ'] = 'u', ['ㄨㄚ'] = 'ua', ['ㄨㄛ'] = 'uo', ['ㄨㄞ'] = 'uai', ['ㄨㄟ'] = 'ui', ['ㄨㄢ'] = 'uan', ['ㄨㄣ'] = 'un', ['ㄨㄤ'] = 'uang', ['ㄨㄥ'] = 'ong', 
		['ㄩ'] = 'ü', ['ㄩㄝ'] = 'ue', ['ㄩㄝ'] = 'üe', ['ㄩㄢ'] = 'üan', ['ㄩㄣ'] = 'ün', ['ㄩㄥ'] = 'iong', 
		['ㄦ'] = 'er', ['ㄫ'] = 'ng', ['ㄇ'] = 'm', [''] = 'i'
	}

	local zhuyin_py_tone = {
		["ˊ"] = "\204\129", ["ˇ"] = "\204\140", ["ˋ"] = "\204\128", ["˙"] = "", [""] = "\204\132"	
	}
  
	if type(text) == "table" then text = text.args[1] end
 	local word = split(text, " ", true)
 	
 	local function process_syllable(syllable)
 		syllable = gsub(syllable, '^([ㄓㄔㄕㄖㄗㄘㄙ])([ˊˇˋ˙]?)$', '%1ㄧ%2')
 		return gsub(syllable, '([ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙ]?)([ㄧㄨㄩ]?[ㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦㄫㄧㄨㄩㄇ])([ˊˇˋ˙]?)(ㄦ?)', function(initial, final, tone, erhua)
			initial = zhuyin_py_initial[initial]
			final = zhuyin_py_final[final]

			if erhua ~= '' then
				final = final .. 'r'
			end
			if initial == '' then
				final = final:gsub('^([iu])(n?g?)$', function(a, b) return a:gsub('[iu]', {['i'] = 'yi', ['u'] = 'wu'}) .. b end)
				final = final:gsub('^(w?u)([in])$', 'ue%2')
				final = final:gsub('^iu$', 'iou')
				final = final:gsub('^([iu])', {['i'] = 'y', ['u'] = 'w'})
				final = final:gsub('^ong', 'weng')
				final = gsub(final, '^ü', 'yu')
			end
			if initial:find('[jqx]') then
				final = gsub(final, '^ü', 'u')
			end
			local tone = zhuyin_py_tone[tone]
			
			if final:find('[ae]') then
				final = final:gsub("([ae])", "%1" .. tone)
			elseif final:find('i[ou]') then
				final = final:gsub("(i[ou])", "%1" .. tone)
			elseif final:find('[io]') then
				final = final:gsub("([io])", "%1" .. tone)
			else
				final = gsub(final, "^([wy]?)(.)", "%1" .. "%2" .. tone)
			end

 			return initial .. final
 		end)
 	end
 	
 	for i, syllable in ipairs(word) do
 		word[i] = process_syllable(syllable)
 	end
  return mw.ustring.toNFC(table.concat(word, " "))
end

function export.py_wg(text)
	local py_wg_initial = {
		["b"] = "p", ["p"] = "pʻ", 
		["d"] = "t", ["t"] = "tʻ", 
		["g"] = "k", ["k"] = "kʻ", 
		["j"] = "ch", ["q"] = "chʻ", ["x"] = "hs", 
		["z"] = "ts", ["c"] = "tsʻ", ["r"] = "j", 
		["zh"] = "ch", ["ch"] = "chʻ", 
	}
	
	local py_wg_final = {
		["^([yw]?)e([^ih])"] = "%1ê%2", 
		["^e$"] = "ê", 
		["([iy])an$"] = "%1en", 
		["(i?)ong"] = "%1ung", 
		["([iy])e$"] = "%1eh", 
		["[uü]e"] = "üeh", 
		["r$"] = "rh", 
		["^ê$"] = "eh", 
		["^i$"] = "i", 
		["yi$"] = "i", 
	}
	
	local py_wg_syl = {
		["(t?sʻ?)uo"] = "%1o", 
		["^([tnlcj]h?ʻ?)uo"] = "%1o",
		["shi"] = "shih", ["ji"] = "jih",
		["tsi"] = "tzŭ", ["tsʻi"] = "tzʻŭ", ["^si$"] = "ssŭ", 
		["^([kh]?ʻ?)ê$"] = "%1o", 
		["yên"] = "yen", 
		["you"] = "yu", ["^ih"] = "i",
		["k(ʻ?)ui"] = "k%1uei"
	}
	
	if type(text) == 'table' then text = text.args[1] end
	local text = gsub(export.py_transform(text, true), '[,%.]', '')
	text = gsub(gsub(text, ' +', ' '), '[一不]', {['一'] = 'yi1', ['不'] = 'bu4'})
	text = gsub(text, '([jqxy])u', '%1ü')
	local p = split(text, " ", true)
	
	local function process_syllable(initial, final, tone)
		for text, replace in pairs(py_wg_final) do
			final = gsub(final, text, replace)
		end
		if (initial == "zh" or initial == "ch") and final == "i" then
			final = "ih"
		end
		local untoned = (py_wg_initial[initial] or initial) .. final
		for text, replace in pairs(py_wg_syl) do
			untoned = gsub(untoned, text, replace)
		end
		return untoned .. '<sup>' .. tone .. '</sup>'
	end

	for i = 1, #p do
		p[i] = gsub(p[i], '^([bcdfghjklmnpqrstxz]?h?)(.+)([1-5])$', process_syllable)
	end
	return table.concat(p, " ")
end

local function temp_bg(text, bg)
	if bg == 'y' then
		return '<' .. text .. '>'
	end
	return text
end
	
local function make_bg(text, bg)
	if bg == 'y' then
		return '<span style="background-color:#F5DEB3">' .. text .. '</span>'
	else
		return text
	end
end

function export.py_gwoyeu(text, original_text)
	local initials = {
		['b'] = 'b',  ['p'] = 'p',  ['m'] = 'm',  ['f'] = 'f', 
		['d'] = 'd',  ['t'] = 't',  ['n'] = 'n',  ['l'] = 'l', 
		['g'] = 'g',  ['k'] = 'k',  ['h'] = 'h', 
		['j'] = 'j',  ['q'] = 'ch',  ['x'] = 'sh', 
		['zh'] = 'j', ['ch'] = 'ch', ['sh'] = 'sh', ['r'] = 'r', 
		['z'] = 'tz', ['c'] = 'ts',  ['s'] = 's', 
		['y'] = 'i',  ['w'] = 'u', 
		[''] = ''
	}
	local finals = {
		['a'] = 'a',   ['ai'] = 'ai',  ['ao'] = 'au',   ['an'] = 'an',   ['ang'] = 'ang',   ['e'] = 'e',   ['ei'] = 'ei',  ['ou'] = 'ou',  ['en'] = 'en',  ['eng'] = 'eng',   ['o'] = 'o', 
		['ia'] = 'ia',         ['iao'] = 'iau',  ['ian'] = 'ian',  ['iang'] = 'iang',  ['ie'] = 'ie',          ['iu'] = 'iou',  ['in'] = 'in',  ['ing'] = 'ing',   ['i'] = 'i', 
		['ua'] = 'ua',  ['uai'] = 'uai',         ['uan'] = 'uan',  ['uang'] = 'uang',  ['uo'] = 'uo',  ['ui'] = 'uei',         ['un'] = 'uen', ['ong'] = 'ong',   ['u'] = 'u', 
		['ɨ'] = 'y',                  ['üan'] = 'iuan',          ['üe'] = 'iue',                 ['ün'] = 'iun', ['iong'] = 'iong',  ['ü'] = 'iu', 
		--erhua
		['ar'] = 'al',  ['air'] = 'al',  ['aor'] = 'aul',  ['anr'] = 'al',  ['angr'] = 'angl',  ['er'] = 'el',  ['eir'] = 'eil', ['our'] = 'oul', ['enr'] = 'el', ['engr'] = 'engl',  ['or'] = 'ol', 
		['iar'] = 'ial',        ['iaor'] = 'iaul', ['ianr'] = 'ial', ['iangr'] = 'iangl', ['ier'] = 'iel',         ['iur'] = 'ioul', ['inr'] = 'iel', ['ingr'] = 'iengl', ['ir'] = 'iel', 
		['uar'] = 'ual', ['uair'] = 'ual',         ['uanr'] = 'ual', ['uangr'] = 'uangl', ['uor'] = 'uol', ['uir'] = 'ueil',        ['unr'] = 'uel', ['ongr'] = 'ongl',  ['ur'] = 'ul', 
		['ɨr'] = 'el',                 ['üanr'] = 'iual',          ['üer'] = 'iuel',                ['ünr'] = 'iul', ['iongr'] = 'iongl', ['ür'] = 'iuel', 
	}
	if type(text) == 'table' then text = text.args[1] end
	if text:find('^%s') or text:find('%s$') then error('invalid spacing') end
	local words = split(text, " ")
	local count = 0
	for i, word in ipairs(words) do
		local uppercase
		if word:find('^%u') then uppercase = true else uppercase = false end
		word = export.py_transform(word, true, true)
		word = gsub(word, "([1-5])", "%1 ")
		word = gsub(word, " $", "")
		word = gsub(word, '([!-/:-@%[-`{|}~！-／：-＠［-｀｛-･])', ' %1 ')
		word = gsub(word, ' +', ' ')
		word = gsub(word, ' $', '')
		word = gsub(word, '^ ', '')
		local syllables = split(word, " ")
		for j, syllable in ipairs(syllables) do
			count = count + 1
			if not find(syllable, '^[!-/:-@%[-`{|}~！-／：-＠［-｀｛-･]+$') then
				local current = sub(mw.title.getCurrentTitle().text, count, count)
				if find(current, '^[一七八不]$') then
					local exceptions = {['一'] = 'i', ['七'] = 'chi', ['八'] = 'ba', ['不'] = 'bu'}
					syllables[j] = exceptions[current]
				else
					local initial, final, tone = '', '', ''
					syllable = gsub(syllable, '([jqxy])u', '%1ü')
					syllable = gsub(syllable, '^([zcsr]h?)i(r?[1-5])$', '%1ɨ%2')
					if mw.ustring.find(syllable, '([bpmfdtnlgkhjqxzcsryw]?h?)([iuü]?[aoeiɨuü][ioun]?g?r?)([1-5])') then
						syllable = gsub(syllable, '([bpmfdtnlgkhjqxzcsryw]?h?)([iuü]?[aoeiɨuü][ioun]?g?r?)([1-5])', function(a, b, c)
							initial = initials[a] or error('Unrecognised initial:' .. a); final = finals[b] or error('Unrecognised final:' .. b); tone = c
							return (initial .. final .. tone) end)
					elseif not find(mw.title.getCurrentTitle().text, "[噷嗯哦呸哼唔呣姆嘸們欸誒M]") then
						error('Unrecognised syllable:' .. syllable)
					end
					local original = initial..final..tone
					if initial:find('^[iu]$') then
						final = initial .. final
						initial = ''
					end
					final = gsub(final, '([iu])%1', '%1')
					local len = len(initial) + len(final)
					local detone = initial..final
					local replace = detone
					local fullstop = false
					if tone == 5 or tone == '5' then
						fullstop = true
						if original_text then
							tone = split(export.py_transform(original_text, true), ' ')[count]:match('[1-5]')
						else tone = 1 end
						if tone == 5 or tone == '5' then
							tone = export.tone_determ(m_zh.py(current))
						end
					end
					if tone == 1 or tone == '1' then
						if initial == 'l' or initial == 'm' or initial == 'n' or initial == 'r' then
							replace = initial .. 'h' .. sub(detone, 2, len)
						else
							replace = detone
						end
					elseif tone == 2 or tone == '2' then
						if not (initial == 'l' or initial == 'm' or initial == 'n' or initial == 'r') then
							if final:sub(1, 1) == 'i' or final:sub(1, 1) == 'u' then
								replace = gsub(detone, '[iu]', {['i'] = 'y', ['u'] = 'w'}, 1)
								if replace:sub(len, len) == 'y' or replace:sub(len, len) == 'w' then
									replace = gsub(replace, '[yw]$', {['y'] = 'yi', ['w'] = 'wu'})
								end
							else
								replace = gsub(detone, '([aiueo]+)', '%1r')
							end
						else
							replace = detone
						end
					elseif tone == 3 or tone == '3' then
						if detone:find('^[iu]') then
							detone = detone:gsub('^[iu]', {['i'] = 'yi', ['u'] = 'wu'})
						end
						if final:find('[aeiou][aeiou]') and not final:find('^[ie][ie]') and not final:find('^[uo][uo]') then
							replace = detone:gsub('[iu]', {['i'] = 'e', ['u'] = 'o'}, 1)
						else
							if final:find('[aoeiuy]') then replace = detone:gsub('[aoeiuy]', '%1%1', 1)
							else error('Unrecognised final:'..final)
							end
						end
					elseif tone == 4 or tone == '4' then
						if detone:find('^[iu]') then
							detone = detone:gsub('^[iu]', {['i'] = 'yi', ['u'] = 'wu'})
						end
						if detone:find('[aeiou][iuln]g?$') then
							replace = detone:gsub('[iuln]g?$', {['i'] = 'y', ['u'] = 'w', ['l'] = 'll', ['n'] = 'nn', ['ng'] = 'nq'})
						else
							replace = detone .. 'h'
						end
						replace = replace:gsub('yi([aeiou])', 'y%1')
						replace = replace:gsub('wu([aeiou])', 'w%1')
					end
					if fullstop then replace = '.' .. replace end
					syllables[j] = syllable:gsub(original, replace)
				end
			end
		end
		words[i] = table.concat(syllables, "")
		if uppercase then
			words[i] = gsub(words[i], '^%l', mw.ustring.upper)
		end
	end
	return table.concat(words, " ")
end

-- Converts Hanyu Pinyin into Tongyong Pinyin.
function export.py_tongyong(text)
	if type(text) == 'table' then text = text.args[1] end
	
	local ty_tone = {
		["1"] = "", ["2"] = "\204\129", ["3"] = "\204\140", ["4"] = "\204\128", ["5"] = "\204\138"
	}
	
	local function num_to_mark(syllable, tone)
		tone = ty_tone[tone]
		if tone ~= "" then
			if syllable:find('[aeê]') then
				syllable = syllable:gsub("([aeê])", "%1" .. tone)
			elseif syllable:find('o') then
				syllable = syllable:gsub("(o)", "%1" .. tone)
			elseif syllable:find('[iu]') then
				syllable = syllable:gsub("([iu])", "%1" .. tone)
			end
		end
		return syllable
	end
	
	local words = {}
	for word in gsplit(text, " ") do
		local cap = word:find("^[A-Z]")
		word = export.py_transform(word, true)
		local syllables = {}
		for syllable in gsplit(word, " ") do
			syllable = syllable:gsub("([zcs]h?)i", "%1ih")
			syllable = syllable:gsub("ü", "yu")
			syllable = syllable:gsub("([jqx])u", "%1yu")
			syllable = syllable:gsub("iu", "iou")
			syllable = syllable:gsub("ui", "uei")
			syllable = syllable:gsub("([wf])eng", "%1ong")
			syllable = syllable:gsub("wen", "wun")
			syllable = syllable:gsub("iong", "yong")
			syllable = syllable:gsub("^zh", "jh")
			syllable = syllable:gsub("^q", "c")
			syllable = syllable:gsub("^x", "s")
			syllable = #syllables ~= 0 and syllable:gsub("^([aeo])", "'%1") or syllable
			syllable = syllable:gsub("^([^1-5]+)([1-5])$", num_to_mark)
			
			table.insert(syllables, syllable)
		end
		word = table.concat(syllables, "")
		word = cap and word:gsub("^.", string.upper) or word
		table.insert(words, word)
	end
	
	return mw.ustring.toNFC(table.concat(words, " "))
end

function export.py_format(text, cap, bg, simple, nolink)
	if cap == false then cap = nil end
	if bg == false then bg = 'n' else bg = 'y' end
	if simple == false then simple = nil end
	if nolink == false then nolink = nil end
	text = mw.ustring.toNFD(text)
	local phon = text
	local title = mw.title.getCurrentTitle().text
	local cat = ''
	local spaced = mw.ustring.toNFD(export.py_transform(text))
	local space_count
	spaced, space_count = gsub(spaced, ' ', '@')
	local consec_third_count
	
	for _ = 1, space_count do
		spaced, consec_third_count = gsub(spaced, "([^@]+)̌([^#@]*)@([^#@]+̌)", function(a, b, c)
			return temp_bg(a..'́'..b, bg)..'@'..c end, 1)
		if consec_third_count > 0 then
			phon = gsub(spaced, '@', '')
		end
	end
	text = gsub(text, "#", "")
	phon = gsub(phon, "#", "")
	
	if title:find('一') and not text:find('一') and not simple then
		cat = cat .. '[[Category:Mandarin words containing 一 not undergoing tone sandhi]]'
	end
	
	if text:find('[一不]') and not simple then
		text = gsub(text, '[一不]$', {['一'] = 'yī', ['不'] = 'bù'})
		phon = gsub(phon, '[一不]$', {['一'] = 'yī', ['不'] = 'bù'})
		
		if find(text, '一') then
			if find(text, '一[^̄́̌̀]*[̄́̌]') then
				cat = cat .. '[[Category:Mandarin words containing 一 undergoing tone sandhi to the fourth tone]]'
				phon = gsub(phon, '一([^̄́̌̀]*[̄́̌])', function(a) return temp_bg('yì', bg) .. a end)
				text = gsub(text, '一([^̄́̌̀]*[̄́̌])', 'yī%1')
			end
			if find(text, '一[^̄́̌̀]*̀') or find(text, '一ge$') or find(text, '一ge[^nr]') then
				cat = cat .. '[[Category:Mandarin words containing 一 undergoing tone sandhi to the second tone]]'
				phon = gsub(phon, '一([^̄́̌̀]*̀)', function(a) return temp_bg('yí', bg) .. a end)
				phon = gsub(phon, '一ge', temp_bg('yí', bg) .. 'ge')
				text = gsub(text, '一([^̄́̌̀]*[̄́̌])', 'yī%1')
			end
		end
		if find(text, '不 ?[bpmfdtnlgkhjqxzcsrwy]?h?[aeiou]*̀') then
			cat = cat .. '[[Category:Mandarin words containing 不 undergoing tone sandhi|2]]'
			phon = gsub(phon, '不( ?[bpmfdtnlgkhjqxzcsrwy]?h?[aeiou]*̀)', function(a) return temp_bg('bú', bg) .. a end)
		end
	end
	text = gsub(text, '[一不]', {['一'] = 'yī', ['不'] = 'bù'})
	text = gsub(text, '兒', function() return make_bg('r', bg) end) -- character is deleted
	phon = gsub(phon, '<([^>]+)>', '<span style="background-color:#F5DEB3">%1</span>')
	
	if not simple then
		if cap then
			text = gsub(text, '^%l', string.upper)
			phon = gsub(phon, '^%l', string.upper)
		end
		if not nolink then
			text = '[[' .. text .. ']]'
		end
		if '[[' .. gsub(phon, '[一不]', {['一'] = 'yī', ['不'] = 'bù'}) .. ']]' ~= text then
			phon = gsub(phon, '[一不]', {['一'] = 'yī', ['不'] = 'bù'})
			text = text .. ' [Phonetic: ' .. phon .. ']'
		end
		if mw.title.getCurrentTitle().nsText ~= 'Template' and not nolink then
			text = text .. cat
		end
	end
	return mw.ustring.toNFC(text)
end

function export.make_tl(original_text, tl_pos, bg, cap)
	if bg == false then bg = 'n' else bg = 'y' end
	local _, countoriginal = gsub(original_text, " ", " ")
	local spaced = export.py_transform(original_text)
	if sub(spaced, -1, -1) == ' ' then spaced = sub(spaced, 1, -2) end
	local _, count = gsub(spaced, " ", " ")
	local index = {}
	local start, finish
	local pos = 1
	for i = 1, count, 1 do
		if i ~= 1 then pos = (index[i-1] + 1) end
		index[i] = mw.ustring.find(spaced, ' ', pos)
	end
	if tl_pos == 2 then
		start = index[count-1] - count + countoriginal + 2
		finish = index[count] - count + countoriginal
	elseif tl_pos == 3 then
		start = index[count-2] - count + countoriginal + 3
		finish = index[count-1] - count + countoriginal + 1
	else
		start = count == 0 and 1 or (index[count] - count + countoriginal + 1)
		finish = -1
	end
	local text = (sub(original_text, 1, start-1) .. make_bg(gsub(sub(original_text, start, finish), '.', py_detone), bg))
	if finish ~= -1 then text = (text .. sub(original_text, finish+1, -1)) end
	if cap == true then text = gsub(text, '^%l', string.upper) end
	return text
end

function export.tag(first, second, third, fourth, fifth)
	local text = "(''"
	local tag = {}
	local tagg = first or "Standard Chinese"
	tag[1] = (second ~= '') and second or "Standard Chinese"
	tag[2] = (third ~= '') and third or nil
	tag[3] = (fourth ~= '') and fourth or nil
	tag[4] = (fifth ~= '') and fifth or nil
	text = text .. ((tagg == '') and table.concat(tag, ", ") or tagg) .. "'')"
	text = gsub(text, 'Standard Chinese', "[[w:Standard Chinese|Standard Chinese]]")
	text = gsub(text, 'Mainland', "[[w:Putonghua|Mainland]]")
	text = gsub(text, 'Taiwan', "[[w:Taiwanese Mandarin|Taiwan]]")
	text = gsub(text, 'Beijing', "[[w:Beijing dialect|Beijing]]")
	text = gsub(text, 'erhua', "[[w:erhua|erhua]]")
	text = gsub(text, 'Min Nan', "[[w:Min Nan|Min Nan]]")
	text = gsub(text, 'shangkouzi', "''[[上口字|shangkouzi]]''")
	return text
end

function export.straitdiff(text, pron_ind, tag)
	local conv_text = text
	for i = 1, #text do
		if m_zh_data().MT[sub(text, i, i)] then conv_text = 'y' end
	end
	if tag == 'tag' then
		conv_text = (conv_text == 'y') and m_zh_data().MT_tag[match(text, '[丁-丌与-龯㐀-䶵]')][pron_ind] or ''
	elseif pron_ind == 1 or pron_ind == 2 or pron_ind == 3 or pron_ind == 4 or pron_ind == 5 then
		local reading = {}
		for a, b in pairs(m_zh_data().MT) do
			reading[a] = b[pron_ind]
			if reading[a] then reading[a] = gsub(reading[a], "^([āōēáóéǎǒěàòèaoe])", "'%1") end
		end
		conv_text = gsub(text, '.', reading)
		text = gsub(text, "^'", "")
		text = gsub(text, " '", " ")
		if conv_text == text and tag == 'exist' then return nil end
	end
	conv_text = gsub(conv_text, "^'", "")
	return conv_text
end

function export.str_analysis(text, conv_type, other_m_vars)
	if type(text) == 'table' then text, conv_type = text.args[1], (text.args[2] or "") end
	local MT = m_zh_data().MT
	
	text = gsub(text, '=', '—')
	text = gsub(text, ',', '隔')
	text = gsub(text, '隔 ', ', ')
	if conv_type == 'head' or conv_type == 'link' then
		if find(text, '隔cap—') then
			text = gsub(text, '[一不]', {['一'] = 'Yī', ['不'] = 'Bù'})
		end
		text = gsub(text, '[一不]', {['一'] = 'yī', ['不'] = 'bù'})
	end
	local comp = split(text, '隔', true)
	local reading = {}
	local alternative_reading = {}
	local zhuyin = {}
	--[[
	-- not used
	local param = {
		'1n', '1na', '1nb', '1nc', '1nd', 'py', 'cap', 'tl', 'tl2', 'tl3', 'a', 'audio', 'er', 'ertl', 'ertl2', 'ertl3', 'era', 'eraudio',
		'2n', '2na', '2nb', '2nc', '2nd', '2py', '2cap', '2tl', '2tl2', '2tl3', '2a', '2audio', '2er', '2ertl', '2ertl2', '2ertl3', '2era', '2eraudio',
		'3n', '3na', '3nb', '3nc', '3nd', '3py', '3cap', '3tl', '3tl2', '3tl3', '3a', '3audio', '3er', '3ertl', '3ertl2', '3ertl3', '3era', '3eraudio',
		'4n', '4na', '4nb', '4nc', '4nd', '4py', '4cap', '4tl', '4tl2', '4tl3', '4a', '4audio', '4er', '4ertl', '4ertl2', '4ertl3', '4era', '4eraudio',
		'5n', '5na', '5nb', '5nc', '5nd', '5py', '5cap', '5tl', '5tl2', '5tl3', '5a', '5audio', '5er', '5ertl', '5ertl2', '5ertl3', '5era', '5eraudio'
	}
	--]]
	
	if conv_type == '' then
		return comp[1]
	elseif conv_type == 'head' or conv_type == 'link' then
		for i, item in ipairs(comp) do
			if not find(item, '—') then
				if find(item, '[一-龯㐀-䶵]') then
					local M, T, t = {}, {}, {}
					for a, b in pairs(MT) do
						M[a] = b[1]; T[a] = b[2]; t[a] = b[3];
						M[a] = gsub(M[a], "^([āōēáóéǎǒěàòèaoe])", "'%1")
						T[a] = gsub(T[a], "^([āōēáóéǎǒěàòèaoe])", "'%1")
						if t[a] then t[a] = gsub(t[a], "^([āōēáóéǎǒěàòèaoe])", "'%1") end
					end
					local mandarin = gsub(item, '.', M)
					local taiwan = gsub(item, '.', T)
					mandarin = gsub(mandarin, "^'", "")
					mandarin = gsub(mandarin, " '", " ")
					if conv_type == 'link' then return mandarin end
					taiwan = gsub(taiwan, "^'", "")
					taiwan = gsub(taiwan, " '", " ")
					local tt = gsub(item, '.', t)
					if find(text, 'cap—') then
						mandarin = gsub(mandarin, '^%l', mw.ustring.upper)
						taiwan = gsub(taiwan, '^%l', mw.ustring.upper)
						tt = gsub(tt, '^%l', mw.ustring.upper)
					end
					if tt == item then
						zhuyin[i] = export.py_zhuyin(mandarin, true) .. ', ' .. export.py_zhuyin(taiwan, true)
						reading[i] = mandarin .. ']], [[' .. taiwan
					else
						tt = gsub(tt, "^'", "")
						tt = gsub(tt, " '", " ")
						zhuyin[i] = export.py_zhuyin(mandarin, true) .. ', ' .. export.py_zhuyin(taiwan, true) .. ', ' .. export.py_zhuyin(tt, true)
						reading[i] = mandarin .. ']], [[' .. taiwan .. ']], [[' .. tt
					end
				else
					if conv_type == 'link' then return item end
					zhuyin[i] = export.py_zhuyin(item, true)
					reading[i] = item
					if len(mw.title.getCurrentTitle().text) == 1 and #mw.text.split(export.py_transform(item), " ") == 1 then
						alternative_reading[i] = "[[" .. export.py_transf(reading[i]) .. "|" .. mw.ustring.gsub(export.py_transf(reading[i]), '([1-5])', '<sup>%1</sup>') .. "]]"
					end
				end
				if reading[i] ~= '' then reading[i] = '[[' .. reading[i] .. ']]' end
				reading[i] = gsub(reading[i], "#", "")
			end
			comp[i] = item
			if conv_type == 'link' then return comp[1] end
		end
		local id = m_zh.ts_determ(mw.title.getCurrentTitle().text)
		local accel
		if id == 'trad' then
			accel = '<span class="form-of pinyin-t-form-of transliteration-' .. m_zh.ts(mw.title.getCurrentTitle().text)
		elseif id == 'simp' then
			accel = '<span class="form-of pinyin-s-form-of transliteration-' .. m_zh.st(mw.title.getCurrentTitle().text)
		elseif id == 'both' then
			accel = '<span class="form-of pinyin-ts-form-of'
		end
		accel = accel .. '" lang="cmn" style="font-family: Consolas, monospace;">'
		local result = other_m_vars and "*: <small>(''[[w:Standard Chinese|Standard]]'')</small>\n*::" or "*:"
		result = result .. "<small>(''[[w:Pinyin|Pinyin]]'')</small>: " .. accel .. gsub(table.concat(reading, ", "), ", ,", ",")
		if alternative_reading[1] then
			result = result .. " (" .. table.concat(alternative_reading, ", ") .. ")"
		end
		result = result .. (other_m_vars and "</span>\n*::" or "</span>\n*:")
		result = result .. "<small>(''[[w:Zhuyin|Zhuyin]]'')</small>: " .. '<span lang="zh-Bopo" class="Bopo">' .. gsub(table.concat(zhuyin, ", "), ", ,", ",") .. "</span>"
		return result

	elseif conv_type == '2' or conv_type == '3' or conv_type == '4' or conv_type == '5' then
		if not find(text, '隔') or (comp[tonumber(conv_type)] and find(comp[tonumber(conv_type)], '—')) then
			return ''
		else
			return comp[tonumber(conv_type)]
		end
	else
		for i = 1, #comp, 1 do
			local target = '^' .. conv_type .. '—'
			if find(comp[i], target) then
				text = gsub(comp[i], target, '')
				return text
			end
		end
		text = ''
	end
	return text
end

function export.homophones(pinyin)
	local text = ''
	if mw.title.getCurrentTitle().nsText == '' then
		local args = hom_data.list[pinyin]
		text = '<div style="visibility:hidden; float:left"><sup><span style="color:#FFF">edit</span></sup></div>'
		for i, term in ipairs(args) do
			if i > 1 then
				text = text .. "<br>"
			end
			if mw.title.new(term).exists and term ~= mw.title.getCurrentTitle().text then
				local forms = { term }
				local content = mw.title.new(term):getContent()
				local template = match(content, "{{zh%-forms[^}]*}}")
				if template then
					local simp = match(template, "|s=([^|}])+")
					if simp then
						table.insert(forms, simp)
					end
					for tradVar in mw.ustring.gmatch(template, "|t[0-9]=([^|}])+") do
						table.insert(forms, tradVar)
					end
					for simpVar in mw.ustring.gmatch(template, "|s[0-9]=([^|}])+") do
						table.insert(forms, simpVar)
					end
					term = table.concat(forms, "／")
				end
			end
			text = text .. mw.getCurrentFrame():expandTemplate{ title = "Template:zh-l", args = { term, tr = "-" } }
		end
		text = text .. '[[Category:Mandarin terms with homophones]]'
	end
	return text
end

local function erhua(word, erhua_pos, pagename)
	local title = split(pagename, '')
	local linked_title = ''
	local syllables = split(export.py_transform(word), ' ')
	local count = #syllables
	erhua_pos = find(erhua_pos, '[1-9]') and split(erhua_pos, ';') or { count }
	for _, pos in ipairs(erhua_pos) do
		pos = tonumber(pos)
		title[pos] = title[pos] .. '兒'
		syllables[pos] = syllables[pos] .. 'r'
	end
	local title = table.concat(title)
	if mw.title.new(title).exists then
		linked_title = ' (' .. m_zh.link(nil, nil, {title, tr='-'}) .. ')'
	end
	for i, syllable in pairs(syllables) do
		if i ~= 1 and mw.ustring.toNFD(syllable):find('^[aeiou]') then
			syllables[i] = "'" .. syllable
		end
	end
	word = table.concat(syllables, '')
	return (export.tag('', '', 'erhua-ed') .. linked_title), word
end

export.erhua = erhua

function export.make(frame)
	local args = frame:getParent().args
	return export.make_args(args)
end

function export.make_args(args)
	local pagename = mw.title.getCurrentTitle().text
	local text = {}
	local reading = {args[1] or '', args[2] or '', args[3] or '', args[4] or '', args[5] or ''}
	args["1nb"] = ine(args["1nb"])
	if reading[1] ~= '' then
		local title = export.tag((args["1n"] or ''), (args["1na"] or ''), (args["1nb"] or export.straitdiff(args[1], 1, 'tag')), (args["1nc"] or ''), (args["1nd"] or ''))
		local pinyin = export.straitdiff(reading[1], 1, '')
		table.insert(text, export.make_table(title, pinyin, (args["py"] or ''), (args["cap"] or ''), (args["tl"] or ''), (args["tl2"] or ''), (args["tl3"] or ''), (args["a"] or args["audio"] or '')))
		
		if args["er"] and args["er"] ~= '' then
			title, pinyin = erhua(pinyin, args["er"], pagename)
			table.insert(text, export.make_table(title, pinyin, '', (args["cap"] or ''), (args["ertl"] or ''), (args["ertl2"] or ''), (args["ertl3"] or ''), (args["era"] or args["eraudio"] or ''), true))
		end
	end
	
	if reading[2] ~= '' or export.straitdiff(reading[1], 2, 'exist') then
		if args["2nb"] and args["2nb"] ~= '' then tagb = args["2nb"] else tagb = export.straitdiff(args[1], 2, 'tag') end
		title = export.tag((args["2n"] or ''), (args["2na"] or ''), tagb, (args["2nc"] or ''), (args["2nd"] or ''))
		pinyin = (reading[2] ~= '') and reading[2] or export.straitdiff(reading[1], 2, '')
		table.insert(text, export.make_table(title, pinyin, (args["2py"] or ''), (args["2cap"] or ''), (args["2tl"] or ''), (args["2tl2"] or ''), (args["2tl3"] or ''), (args["2a"] or args["2audio"] or ''), true))
		table.insert(text, '[[Category:Mandarin terms with multiple pronunciations|' .. (export.straitdiff(args[1], 1, '') or args[1]) .. ']]')
		
		if args["2er"] and args["2er"] ~= '' then
			title, pinyin = erhua(pinyin, args["2er"], pagename)
			table.insert(text, export.make_table(title, pinyin, '', (args["2cap"] or ''), (args["2ertl"] or ''), (args["2ertl2"] or ''), (args["2ertl3"] or ''), (args["2era"] or args["2eraudio"] or ''), true))
		end
		
		if reading[3] ~= '' or export.straitdiff(reading[1], 3, 'exist') then
			if args["3nb"] and args["3nb"] ~= '' then tagb = args["3nb"] else tagb = export.straitdiff(args[1], 3, 'tag') end
			title = export.tag((args["3n"] or ''), (args["3na"] or ''), tagb, (args["3nc"] or ''), (args["3nd"] or ''))
			if reading[3] ~= '' then pinyin = reading[3] else pinyin = export.straitdiff(reading[1], 3, '') end
			table.insert(text, export.make_table(title, pinyin, (args["3py"] or ''), (args["3cap"] or ''), (args["3tl"] or ''), (args["3tl2"] or ''), (args["3tl3"] or ''), (args["3a"] or args["3audio"] or ''), true))
			
			if args["3er"] and args["3er"] ~= '' then
				title, pinyin = erhua(pinyin, args["3er"], pagename)
				table.insert(text, export.make_table(title, pinyin, '', (args["3cap"] or ''), (args["3ertl"] or ''), (args["3ertl2"] or ''), (args["3ertl3"] or ''), (args["3era"] or args["3eraudio"] or ''), true))
			end
			
			if reading[4] ~= '' or export.straitdiff(reading[1], 4, 'exist') then
				if args["4nb"] and args["4nb"] ~= '' then tagb = args["4nb"] else tagb = export.straitdiff(args[1], 4, 'tag') end
				title = export.tag((args["4n"] or ''), (args["4na"] or ''), tagb, (args["4nc"] or ''), (args["4nd"] or ''))
				if reading[4] ~= '' then pinyin = reading[4] else pinyin = export.straitdiff(reading[1], 4, '') end
				table.insert(text, export.make_table(title, pinyin, (args["4py"] or ''), (args["4cap"] or ''), (args["4tl"] or ''), (args["4tl2"] or ''), (args["4tl3"] or ''), (args["4a"] or args["4audio"] or ''), true))
			
				if args["4er"] and args["4er"] ~= '' then
					title, pinyin = erhua(pinyin, args["4er"], pagename)
					table.insert(text, export.make_table(title, pinyin, '', (args["4cap"] or ''), (args["4ertl"] or ''), (args["4ertl2"] or ''), (args["4ertl3"] or ''), (args["4era"] or args["4eraudio"] or ''), true))
				end
				if reading[5] ~= '' or export.straitdiff(reading[1], 5, 'exist') then
					if args["5nb"] and args["5nb"] ~= '' then tagb = args["5nb"] else tagb = export.straitdiff(args[1], 5, 'tag') end
					title = export.tag((args["5n"] or ''), (args["5na"] or ''), tagb, (args["5nc"] or ''), (args["5nd"] or ''))
					if reading[5] ~= '' then pinyin = reading[5] else pinyin = export.straitdiff(reading[1], 5, '') end
					table.insert(text, export.make_table(title, pinyin, (args["5py"] or ''), (args["5cap"] or ''), (args["5tl"] or ''), (args["5tl2"] or ''), (args["5tl3"] or ''), (args["5a"] or args["5audio"] or ''), true))
				
					if args["5er"] and args["5er"] ~= '' then
						title, pinyin = erhua(pinyin, args["5er"], pagename)
						table.insert(text, export.make_table(title, pinyin, '', (args["5cap"] or ''), (args["5ertl"] or ''), (args["5ertl2"] or ''), (args["5ertl3"] or ''), (args["5era"] or args["5eraudio"] or ''), true))
					end
				end
			end
		end
	end
	if (args["tl"] or '') .. (args["tl2"] or '') .. (args["tl3"] or '') .. (args["2tl"] or '') .. (args["2tl2"] or '') .. (args["2tl3"] or '') ~= '' then
		table.insert(text, '[[Category:Mandarin words containing toneless variants|' .. export.straitdiff(args[1], 1, '') .. ']]')
	end
	return table.concat(text)
end

function export.make_audio(args)
	local text, reading, pinyin = {}, {}, ""
	local audio = {
		args["a"] or args["audio"] or '',
		args["2a"] or args["2audio"] or '',
		args["3a"] or args["3audio"] or '',
		args["4a"] or args["4audio"] or '',
		args["5a"] or args["5audio"] or '',
	}
	for i=1,5 do
		reading[i] = args[i] or ''
		if i == 1 then
			pinyin = export.straitdiff(reading[1], 1, '')
		else
			pinyin = (reading ~= '') and reading[i] or export.straitdiff(reading[1], i, '')
		end
		pinyin = export.py_format(pinyin, false, false, true)
		add_audio(text, audio[i], pinyin)
	end
	return table.concat(text)
end

function add_audio(text, audio, pinyin)
	if audio and audio ~= "" then
		if audio == "y" then audio = string.format('zh-%s.ogg', pinyin) end
		table.insert(text, '\n*:: [[File:')
		table.insert(text, audio)
		table.insert(text, ']]')
		table.insert(text, '[[Category:Mandarin terms with audio links]]')
	end
end

function export.make_table(title, pinyin, py, cap, tl, tl2, tl3, a, novariety)
	py = ine(py);cap = ine(cap);tl = ine(tl);tl2 = ine(tl2);tl3 = ine(tl3);a = ine(a);novariety = ine(novariety)
	local text = {}
	
	local pinyin_simple_fmt = export.py_format(pinyin, false, false, true)
	local pinyin_simple_fmt_nolink = export.py_format(pinyin, false, false, true, true)
	
	if not novariety then
		table.insert(text, '* [[w:Mandarin Chinese|Mandarin]]')
	else
		table.insert(text, '<br>')
	end
	table.insert(text, '\n** <small>' .. title .. '</small>')
	local hom_found
	if hom_data.list[mw.ustring.lower(pinyin_simple_fmt)] then
		hom_found = true
	else
		hom_found = false
		table.insert(text, '<sup><small><abbr title="Add Mandarin homophones"><span class="plainlinks">[' .. tostring(mw.uri.fullUrl("Module:zh/data/cmn-hom",{["action"]="edit"})) .. ' +]</span></abbr></small></sup>')
	end
	table.insert(text, "\n*** <small>''[[w:Pinyin|Pinyin]]''</small>: ")
	local id = m_zh.ts_determ(mw.title.getCurrentTitle().text)
	if id == 'trad' then
		table.insert(text, '<span class="form-of pinyin-t-form-of transliteration-')
		table.insert(text, m_zh.ts(mw.title.getCurrentTitle().text))
	elseif id == 'simp' then
		table.insert(text, '<span class="form-of pinyin-s-form-of transliteration-')
		table.insert(text, m_zh.st(mw.title.getCurrentTitle().text))
	else -- both
		table.insert(text, '<span class="form-of pinyin-ts-form-of')
	end
	table.insert(text, '" lang="cmn" style="font-family: Consolas, monospace;">')
	if py then
		table.insert(text, py)
	else
		if cap then
			table.insert(text, export.py_format(pinyin, true, true))
		else
			table.insert(text, export.py_format(pinyin, false, true))
		end
		if tl or tl2 or tl3 then
			table.insert(text, ' → ')
			if tl then tl_pos = 1 elseif tl2 then tl_pos = 2 elseif tl3 then tl_pos = 3 end
			if cap then
				table.insert(text, export.make_tl(export.py_format(pinyin, true, false, true, true), tl_pos, true, true))
			else
				table.insert(text, export.make_tl(pinyin_simple_fmt_nolink, tl_pos, true))
			end
		end
		if tl then table.insert(text, ' <small>(toneless final syllable variant)</small>')
			elseif tl2 or tl3 then table.insert(text, ' <small>(toneless variant)</small>') end
	end
	table.insert(text, "</span>\n*** <small>''[[w:Zhuyin|Zhuyin]]''</small>: ")
	table.insert(text, '<span lang="zh-Bopo" class="Bopo">')
	table.insert(text, export.py_zhuyin(pinyin_simple_fmt, true))
	if tl or tl2 or tl3 then
		table.insert(text, ' → ')
		table.insert(text, export.py_zhuyin(export.make_tl(pinyin_simple_fmt_nolink, tl_pos, false), true))
	end
	table.insert(text, '</span>')
	if tl then table.insert(text, ' <small>(toneless final syllable variant)</small>')
		elseif tl2 or tl3 then table.insert(text, ' <small>(toneless variant)</small>') end
	if len(mw.title.getCurrentTitle().text) == 1 then
		table.insert(text, "\n*** <small>''[[w:Wade–Giles|Wade–Giles]]''</small>: <code>")
		table.insert(text, export.py_wg(pinyin_simple_fmt))
		table.insert(text, '</code>')
	end
	table.insert(text, "\n*** <small>''[[w:Gwoyeu Romatzyh|Gwoyeu Romatzyh]]''</small>: <code>")
	if tl or tl2 or tl3 then
		table.insert(text, export.py_gwoyeu(export.make_tl(pinyin_simple_fmt_nolink, tl_pos, false), pinyin_simple_fmt))
	else
		table.insert(text, export.py_gwoyeu(pinyin_simple_fmt))
	end
	table.insert(text, '</code>')
	table.insert(text, "\n*** <small>''[[w:Tongyong Pinyin|Tongyong Pinyin]]''</small>: <code>")
	if tl or tl2 or tl3 then
		table.insert(text, export.py_tongyong(export.make_tl(pinyin_simple_fmt_nolink, tl_pos, false), pinyin_simple_fmt))
	else
		table.insert(text, export.py_tongyong(pinyin_simple_fmt))
	end
	table.insert(text, '</code>')
	table.insert(text, '\n*** <small>Sinological [[Wiktionary:International Phonetic Alphabet|IPA]] <sup>([[Appendix:Mandarin pronunciation|key]])</sup></small>: <span class="IPA">/')
	table.insert(text, export.py_ipa(pinyin))
	if tl or tl2 or tl3 then
		table.insert(text, '/ → /')
		table.insert(text, export.py_ipa(export.make_tl(pinyin_simple_fmt_nolink, tl_pos, false)))
	end
	table.insert(text, '/</span>')
	-- if a then
	-- 	if a == 'y' then a = 'zh-' .. pinyin_simple_fmt .. '.ogg' end
	-- 	table.insert(text, '\n*** <div style="display:inline-block; position:relative; top:0.5em;">[[File:')
	-- 	table.insert(text, a)
	-- 	table.insert(text, ']]</div>[[Category:Mandarin terms with audio links]]')
	-- end
	if hom_found then
		table.insert(text, "\n*** <small>Homophones</small>: " ..
			'<table class="wikitable" style="width:15em;margin:0; position:left; text-align:center">' ..
			'<tr><th class="mw-customtoggle-cmnhom" style="color:#3366bb">[Show/Hide]</th></tr>' ..
			'<tr class="mw-collapsible mw-collapsed" id="mw-customcollapsible-cmnhom">' ..
			'<td><sup><div style="float: right; clear: right;"><span class="plainlinks">[')
		table.insert(text, tostring(mw.uri.fullUrl("Module:zh/data/cmn-hom", {["action"]="edit"})))
		table.insert(text, ' edit]</span></div></sup>')
		table.insert(text, export.homophones(mw.ustring.lower(pinyin_simple_fmt)))
		table.insert(text, '</td></tr></table>')
	end
	return table.concat(text)
end

return export