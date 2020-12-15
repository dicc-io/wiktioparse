local export = {}

-- ɟ, ʂ, and ʃ are used internally to represent [ʝ⁓ɟ͡ʝ], [ʃ], and [t͡ʃ]
function export.convertToIPA(word, LatinAmerica, phonetic, do_debug)
	local debug = {}
	
	if type(word) == 'table' then
		do_debug = word.args[4]
		word = word.args[1]
	end
	local orig_word = word
	word = mw.ustring.lower(word or mw.title.getCurrentTitle().text)
	word = mw.ustring.gsub(word, "[^abcdefghijklmnopqrstuvwxyzáéíóúüñ.]", "")
	
	table.insert(debug, word)
	
	local V = "[aeiouáéíóú]" -- vowel
	local W = "[jw]"
	local C = "[^aeiouáéíóú.]" -- consonant
	--determining whether "y" is a consonant or a vowel + diphthongs, "-mente" suffix
	word = mw.ustring.gsub(word, "y(" .. C .. ")", "i%1")
	word = mw.ustring.gsub(word, "y(" .. V .. ")", "ɟ%1") -- not the real sound
	word = mw.ustring.gsub(word, "hi(" .. V .. ")", "ɟ%1")
	word = mw.ustring.gsub(word, "y$", "ï")
    word = mw.ustring.gsub(word, "mente$", "ménte")
	
	--x
	word = mw.ustring.gsub(word, "x", "ks")
	
	--"c" & "g" before "i" and "e" and all that stuff
	word = mw.ustring.gsub(word, "c([ieíé])", (LatinAmerica and 's' or 'θ') .. "%1")
	word = mw.ustring.gsub(word, "gü([ieíé])", "ɡw%1")
	word = mw.ustring.gsub(word, "ü", "")
	word = mw.ustring.gsub(word, "gu([ieíé])", "ɡ%1")
	word = mw.ustring.gsub(word, "g([ieíé])", "x%1")

	table.insert(debug, word)
	
	--alphabet-to-phoneme
	word = mw.ustring.gsub(word, "qu", "c")
	word = mw.ustring.gsub(word, "ch", "ʃ") --not the real sound
	word = mw.ustring.gsub(word, "sh", "ʂ") --not the real sound
	word = mw.ustring.gsub(word, '[cgjñrvy]',
		--['g']='ɡ':  U+0067 LATIN SMALL LETTER G → U+0261 LATIN SMALL LETTER SCRIPT G
		{['c']='k', ['g']='ɡ', ['j']='x', ['ñ']='ɲ', ['r']='ɾ', ['v']='b' })
	
	-- trill in #r, lr, nr, rr
	local match_count = 0
	word = mw.ustring.gsub(
		word,
		'(.?)ɾ(.?)',
		function (before, after)
			match_count = match_count + 1
			-- mw.log(word, before, after)
			if match_count == 1 and before == '' or before == 'l' or before == 'n'
					or after ~= '' and ('bdfɡklʎmnɲpstxzʃʂɟ'):match(after) then
				return before .. 'r' .. after
			elseif before == 'ɾ' then
				return 'r' .. after
			elseif after == 'ɾ' then
				return before .. 'r'
			end
		end)
	
	word = mw.ustring.gsub(word, 'n([bm])', 'm%1')
	word = mw.ustring.gsub(word, 'll', LatinAmerica and 'ɟ' or 'ʎ')
	word = mw.ustring.gsub(word, 'z', LatinAmerica and 'z' or 'θ') -- not the real LatAm sound
	
	table.insert(debug, word)
	
	--syllable division
	for _ = 1, 2 do
		word = mw.ustring.gsub(word,
			"(" .. V .. ")(" .. C .. W .. "?" .. V .. ")",
			"%1.%2")
	end
	for _ = 1, 2 do
		word = mw.ustring.gsub(word,
			"(" .. V .. C .. ")(" .. C .. V .. ")",
			"%1.%2")
	end
	for _ = 1, 2 do
		word = mw.ustring.gsub(word,
			"(" .. V .. C .. ")(" .. C .. C .. V .. ")",
			"%1.%2")
	end
	word = mw.ustring.gsub(word, "([pbktdɡ])%.([lɾ])", ".%1%2")
	word = mw.ustring.gsub(word, "(" .. C .. ")%.s(" .. C .. ")", "%1s.%2")
	word = mw.ustring.gsub(word, "([aeoáéíóú])([aeoáéíóú])", "%1.%2")
	word = mw.ustring.gsub(word, "([ií])([ií])", "%1.%2")
	word = mw.ustring.gsub(word, "([uú])([uú])", "%1.%2")

	table.insert(debug, word)
	
	--diphthongs
	word = mw.ustring.gsub(word, 'ih?([aeouáéóú])', 'j%1')
	word = mw.ustring.gsub(word, 'uh?([aeioáéíó])', 'w%1')
	
	table.insert(debug, word)
	
	--accentuation
	local syllables = mw.text.split(word, "%.")
	if mw.ustring.find(word, "[áéíóú]") then
		for i = 1, #syllables do
			if mw.ustring.find(syllables[i], "[áéíóú]") then
				syllables[i] = "ˈ"..syllables[i]
			end
		end
	else
		if mw.ustring.find(word, "[^aeiouns]$") then
			syllables[#syllables] = "ˈ" .. syllables[#syllables]
		else
			if #syllables > 1 then
				syllables[#syllables-1] = "ˈ" .. syllables[#syllables-1]
			end
		end
	end

	table.insert(debug, word)
	
	--syllables nasalized if ending with "n", voiceless consonants in syllable-final position to voiced
	local remove_accent = { ['á'] = 'a', ['é'] = 'e', ['í'] = 'i', ['ó'] = 'o', ['ú'] = 'u'}
	local nasalize = { ['a'] = 'ã', ['e'] = 'ẽ', ['i'] = 'ĩ', ['o'] = 'õ', ['u'] = 'ũ' }
	for i = 1, #syllables do
		syllables[i] = mw.ustring.gsub(syllables[i], '[áéíóú]', remove_accent)
		if phonetic and mw.ustring.find(syllables[i], '[mnɲ]' .. C .. '?$') then
			syllables[i] = mw.ustring.gsub(syllables[i], '[aeiou]', nasalize)
		end
		syllables[i] = mw.ustring.gsub(syllables[i], '[ptk]$', { ['p'] = 'b', ['t'] = 'd', ['k'] = 'ɡ' })
	end
	word = table.concat(syllables)
	
	--real sound of LatAm Z
	word = mw.ustring.gsub(word, 'z', 's')
	--secondary stress
	word = mw.ustring.gsub(word, 'ˈ(.+)ˈ', 'ˌ%1ˈ')
	word = mw.ustring.gsub(word, 'ˈ(.+)ˌ', 'ˌ%1ˌ')
	word = mw.ustring.gsub(word, 'ˌ(.+)ˈ(.+)ˈ', 'ˌ%1ˌ%2ˈ')

	--phonetic transcription
	if phonetic then
		--θ, s, f before voiced consonants
		local voiced = 'mnɲbdɟɡʎ'
		local r = 'ɾr'
		local tovoiced = {
			['θ'] = 'θ̬',
			['s'] = 'z',
			['f'] = 'v',
		}
		local function voice(sound, following)
			return tovoiced[sound]..following
		end
		word = mw.ustring.gsub(word, '([θs])([ˈˌ]?['..voiced..r..'])', voice)
		word = mw.ustring.gsub(word, '(f)([ˈˌ]?['..voiced..'])', voice)
		
		local stop_to_fricative = {['b']='β', ['d']='ð', ['ɟ']='ʝ', ['ɡ']='ɣ'}
		local fricative_to_stop = {['β']='b', ['ð']='d', ['ʝ']='ɟ', ['ɣ']='ɡ'}
		--lots of allophones going on
		word = mw.ustring.gsub(word, '[bdɟɡ]', stop_to_fricative)
		word = mw.ustring.gsub(
			word,
			'()([ˈˌ]?)([βðɣʝ])',
			function (pos, stress, fricative)
				-- Matching the character before the fricative in the pattern
				-- doesn't work because sometimes there are two fricatives in
				-- a row.
				local before = pos > 1 and mw.ustring.sub(word, pos - 1, pos - 1)
				-- mw.log(orig_word, before, stress, fricative)
				if not before or (fricative == 'ɣ' or fricative == 'β') and ('mnɲ'):find(before)
						or (fricative == 'ð' or fricative == 'ʝ') and ('lʎmnɲ'):find(before) then
					return stress .. fricative_to_stop[fricative]
				end -- else no change
			end)
		word = mw.ustring.gsub(word, '[td]', {['t']='t̪', ['d']='d̪'})
		--nasal assimilation before consonants
		local labiodental, dentialveolar, dental, alveolopalatal, palatal, velar =
			'ɱ', 'n̪', 'n̟', 'nʲ', 'ɲ', 'ŋ'
		local nasal_assimilation = {
			['f'] = labiodental,
			['t'] = dentialveolar, ['d'] = dentialveolar,
			['θ'] = dental,
			['ʃ'] = alveolopalatal,
			['ʂ'] = alveolopalatal,
			['ɟ'] = palatal, ['ʎ'] = palatal,
			['k'] = velar, ['x'] = velar, ['ɡ'] = velar,
		}
		
		word = mw.ustring.gsub(
			word,
			'n([ˈˌ]?)(.)',
			function (stress, following)
				return (nasal_assimilation[following] or 'n') .. stress .. following
			end)
		--lateral assimilation before consonants
		word = mw.ustring.gsub(
			word,
			'l([ˈˌ]?)(.)',
			function (stress, following)
				local l = 'l'
				if following == 't' or following == 'd' then -- dentialveolar
					l = 'l̪'
				elseif following == 'θ' then -- dental
					l = 'l̟'
				elseif following == 'ʃ' then -- alveolopalatal
					l = 'lʲ'
				end
				return l .. stress .. following
			end)
		--semivowels
		word = mw.ustring.gsub(word, '([aeouãẽõũ][iïĩ])', '%1̯')
		word = mw.ustring.gsub(word, '([aeioãẽĩõ][uũ])', '%1̯')
	end
	
	table.insert(debug, word)
	
	word = mw.ustring.gsub(word, 'h', '') --silent "h"
	word = mw.ustring.gsub(word, 'ʃ', 't͡ʃ') --fake "ch" to real "ch"
	word = mw.ustring.gsub(word, 'ʂ', 'ʃ') --fake "sh" to real "sh"
	word = mw.ustring.gsub(word, 'ɟ', 'ɟ͡ʝ') --fake "y" to real "y"
	word = mw.ustring.gsub(word, 'ï', 'i') --fake "y$" to real "y$"
	
	if do_debug == 'yes' then
		return word .. table.concat(debug, "")
	else
		return word
	end
end

function export.LatinAmerica(frame)
	return export.show(frame, true)
end

function export.phonetic(frame)
	return export.show(frame, false, true)
end

function export.phoneticLatinAmerica(frame)
	return export.show(frame, true, true)
end

return export