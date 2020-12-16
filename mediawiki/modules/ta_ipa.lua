local export = {}

local consonants = {
	['க']='k', ['ங']='ŋ', ['ச']='t͡ʃ', ['ஞ']='ɲ', ['ட']='ʈ', ['ண']='ɳ', ['த']='t̪',
	['ந']='n̪', ['ப']='p', ['ம']='m', ['ய']='j', ['ர']='ɾ̪', ['ல']='l̪', ['வ']='ʋ',
	['ழ']='ɻ', ['ள']='ɭ', ['ற']='r', ['ன']='n', ['ஶ']='ɕ', ['ஜ']='d͡ʑ', ['ஷ']='ʂ',
	['ஸ']='s', ['ஹ']='h', ['ஃப']='f', ['ஃஜ']='z', ['ஃஸ']='x',
	['ஃ']='',
}

local diacritics = {
	['ா']= 'aː', ['ி']='i', ['ீ']='iː', ['ு']='u', ['ூ']='uː',  ['ெ']='e',
	['ே']='eː', ['ை']='aɪ̯', ['ொ']='o', ['ோ']='oː', ['ௌ']='aʊ̯',
	['்']='',	--halant, supresses the inherent vowel "a"
	-- no diacritic
	[''] = 'a'
}

local nonconsonants = {
	-- vowels
	['அ']='ʔa', ['ஆ']='ʔaː', ['இ']='ʔi', ['ஈ']='ʔiː', ['உ']='ʔu', ['ஊ']='ʔuː',
	['எ']='ʔe', ['ஏ']='ʔeː', ['ஐ']='ʔaɪ̯', ['ஒ']='ʔo', ['ஓ']='ʔoː', ['ஔ']='ʔaʊ̯',
	-- other symbols
--	['ஃ']='',
}

local adjust1 = {
	['ŋk']='ŋɡ', ['ɲt͡ʃ']='ɲd͡ʑ', ['ɳʈ']='ɳɖ', ['n̪t̪']='n̪d̪', ['mp']='mb',
	['ŋr']='ŋɡɾ', ['ɲr']='ɲd͡ʑɾ', ['ɳr']='ɳɖɾ', ['n̪r']='n̪d̪ɾ', ['mr']='mbɾ', ['rr']='ʈʈɾ',
	['([aeiou]ː?)k([aeiou])']='%1ɡ%2', ['([aeiou]ː?)t͡ʃ([aeiou])']='%1s%2',
	['([aeiou]ː?)ʈ([aeiou])']='%1ɖ%2', ['([aeiou]ː?)t̪([aeiou])']='%1d̪%2', ['([aeiou]ː?)p([aeiou])']='%1b%2',
}

local adjust2 = {
	['t͡ʃ'] = 's',
	['a([^ː])']='ʌ%1', ['aː']='ɑː',
	['i([^ː])']='ɨ%1', --['i$']='ɨ',
	['u([^ː])']='ɯ%1', ['u$']='ɯ',
}

function export.convertToIPA(text)

	text = mw.ustring.gsub(
		text,
		'(ஃ?)([க-ஹ])([ா-்]?)',
		function(h, c, d)
			return (consonants[h..c] or consonants[h] .. (consonants[c] or c)) .. diacritics[d]
		end)

	text = mw.ustring.gsub(text, '[அ-ஔ]', nonconsonants)

	for k, v in pairs(adjust1) do
		text = mw.ustring.gsub(text, k, v)
		text = mw.ustring.gsub(text, k, v) --twice
	end

	--convert consonant gemination to triangular colon
	text = mw.ustring.gsub(text, "([kŋɲʈɳpmjʋɻɭrnɕʂshfzx])%1", "%1ː")
	text = mw.ustring.gsub(text, "([tnɾl]̪)%1", "%1ː")
	text = mw.ustring.gsub(text, "([td]͡[ʃʑ])%1", "%1ː")

	text2 = text --phonetic

	for k, v in pairs(adjust2) do
		text2 = mw.ustring.gsub(text2, k, v)
	end

    return text
	--return (text == text2 and { text } or { text, text2 })

end

function export.show(frame)

	local args = frame:getParent().args
	local page_title = mw.title.getCurrentTitle().text
	local text = args[1] or page_title
	local qualifier = args['q'] or nil

	local transcriptions = export.to_IPA(text)
	local IPA_text
	if not transcriptions[2] then
		IPA_text = require('Module:IPA').format_IPA_full(
			require('Module:languages').getByCode('ta'),
			{ { pron = '/' .. transcriptions[1] .. '/' } })
	else
		IPA_text = require('Module:IPA').format_IPA_full(
			require('Module:languages').getByCode('ta'),
			{ { pron = '/' .. transcriptions[1] .. '/' }, { pron = '[' .. transcriptions[2] .. ']' } })
	end

	return '* ' .. (qualifier and require("Module:qualifier").format_qualifier{qualifier} .. ' ' or '')
		.. IPA_text

end

return export
