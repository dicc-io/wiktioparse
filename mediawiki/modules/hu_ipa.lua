local export = {}
local gsub = mw.ustring.gsub
local match = mw.ustring.match

local replace_set = {
	[1] = {
		['c'] = 'ʦ',
		['cssz'] = 'ʧṡ', ['szsz'] = 'ṡṡ', ['tssz'] = 'ʦʦ', ['zssz'] = 'sṡ', 
		['ggy'] = 'ɟɟ', ['nny'] = 'ɲɲ', ['[dt]ty'] = 'cc',
	},
	[2] = {
		['dzs'] = 'ʤ', ['ddzs'] = 'ʤʤ', ['ssz'] = 'ṡṡ', ['szs'] = 'ss',
		['tsz'] = 'ʦʦ', ['dsz'] = 'ʦʦ', ['tts'] = 'ʧʧ',
		['gysz'] = 'cṡ', ['ttysz'] = 'ʦʦ', ['ttʦ'] = 'ʦʦ',
		['ngy'] = 'ɲɟ', ['ʦszs'] = 'ʤʒ',
		['gyj'] = 'ɟɟ', ['nyj'] = 'ɲɲ', ['tyj'] = 'cc',
		['llj'] = 'jj', ['ttj'] = 'cc',
		['lr'] = 'rr',
	},
	[3] = {
		['ʦs'] = 'ʧ', ['dz'] = 'ʣ',
		['gy'] = 'ɟ', ['ly'] = 'j', ['ny'] = 'ɲ',
		['ty'] = 'c', ['lj'] = 'jj', ['nj'] = 'ɲɲ',
		['tj'] = 'cc', ['dj'] = 'ɟɟ', ['tʦ'] = 'ʦʦ',
		['dʦ'] = 'ʦʦ', ['ts'] = 'ʧʧ', ['ds'] = 'ʧʧ',
		['gys'] = 'cʃ', ['gycs'] = 'cʧ',
		['qu'] = 'kv', ['sz'] = 'ṡ', ['z#s'] = 'ʃʃ', ['zs'] = 'ʒ', 
	},
	[4] = {
		['s'] = 'ʃ', ['ʦʧ'] = 'ʧʧ',
		['w'] = 'v', ['x'] = 'kṡ',
	},
}

local replace_cons = {
	['c'] = 'ʦ', ['cs'] = 'ʧ', ['ccs'] = 'ʧʧ', ['cszs'] = 'ʤʒ', ['cssz'] = 'ʧṡ',
	['dc'] = 'ʦʦ', ['dj'] = 'ɟɟ', ['ds'] = 'ʧʧ', ['dsz'] = 'ʦʦ', ['dty'] = 'cc',
	['dz'] = 'ʣ', ['ddz'] = 'ʣʣ',
	['dzs'] = 'ʤ', ['ddzs'] = 'ʤʤ', ['dzssz'] = 'ʧs',
	['gy'] = 'ɟ', ['ggy'] = 'ɟɟ', ['gycs'] = 'cʧ', ['gyj'] = 'ɟɟ', ['gys'] = 'cʃ', ['gysz'] = 'cṡ', 
	['lj'] = 'jj', ['llj'] = 'jj', ['lr'] = 'rr', ['ly'] = 'j', 
	['ngy'] = 'ɲɟ', ['nj'] = 'ɲɲ', ['nny'] = 'ɲɲ', ['ny'] = 'ɲ', ['nyj'] = 'ɲɲ', 
	['s'] = 'ʃ', ['ssz'] = 'ṡṡ', ['sz'] = 'ṡ', ['szs'] = 'ʃʃ', ['szsz'] = 'ṡṡ',
	['tc'] = 'ʦʦ', ['tj'] = 'cc', ['ts'] = 'ʧʧ', ['tssz'] = 'ʦʦ', ['tsz'] = 'ʦʦ',
	['ttc'] = 'ʦʦ', ['ttj'] = 'cc', ['tts'] = 'ʧʧ',
	['tty'] = 'cc', ['ty'] = 'c', ['tyj'] = 'cc',
	['w'] = 'v', 
	['x'] = 'kṡ',
	['zs'] = 'ʒ', ['zzs'] = 'ʒʒ', ['z#s'] = 'ʃʃ', ['zssz'] = 'ʃs',
}

local replace_vowels = {
	['y'] = 'i', 
	['a'] = 'ɒ', ['á'] = 'aː',
	['e'] = 'ɛ', ['é'] = 'eː', ['ë'] = 'e',
	['i'] = 'i', ['í'] = 'iː',
	['o'] = 'o', ['ó'] = 'oː',
	['ö'] = 'ø', ['ő'] = 'øː',
	['u'] = 'u', ['ú'] = 'uː',
	['ü'] = 'y', ['ű'] = 'yː',
}

local back_replace = {
	['ʦ'] = 't͡s', ['ʣ'] = 'd͡z',
	['ʧ'] = 't͡ʃ', ['ʤ'] = 'd͡ʒ',
	['ṡ'] = 's',
	['g'] = 'ɡ', ['χ'] = 'x',
	['#'] = '',
}

local nasal_assim = {
	['k'] = 'ŋ', ['g'] = 'ŋ',
	['c'] = 'ɲ', ['ɟ'] = 'ɲ', ['ɲ'] = 'ɲ',
	['f'] = 'ɱ', ['v'] = 'ɱ',
	['p'] = 'm', ['b'] = 'm', ['m'] = 'm',
}

local voicing_assim = {
	['devoicing'] = {
		['b'] = 'p', ['v'] = 'f', 
		['d'] = 't', ['z'] = 'ṡ', ['ʣ'] = 'ʦ',
		['ʒ'] = 'ʃ', ['ʤ'] = 'ʧ', 
		['ɟ'] = 'c', ['ʝ'] = 'ç',
		['g'] = 'k',
	},
	['voicing'] = {
		['p'] = 'b', ['f'] = 'v',
		['t'] = 'd', ['ṡ'] = 'z', ['ʦ'] = 'ʣ', 
		['ʃ'] = 'ʒ', ['ʧ'] = 'ʤ',
		['c'] = 'ɟ', 
		['k'] = 'g',
	},
}

local sonorant = {
	['m'] = true, ['n'] = true, ['ny'] = true,
	['l'] = true, ['j'] = true, ['r'] = true,
}

function export.convertToIPA(word)
	-- local args = type(frame) == 'string' and { frame } or frame:getParent().args
	-- local result = {}
	
	-- if args['phon'] and args['phon'] ~= '' then
	-- 	args = { args['phon'] }
	-- end
	-- args = (not args[1]) and { mw.title.getCurrentTitle().text } or args

    -- for _, text in ipairs(args) do
    
    text = word
		text = mw.ustring.lower(text)
	
		local non_i, i_vowels, vowels = '([aeouëöüáéóőúű])', '([iíé])', '([aeiouëöüáéíóőúű])'
	
		if mw.ustring.len(gsub(text, '[^ ]', '')) == 1 then
			text = gsub(text, ' ', '#')
		end
	
		-- j-allophony
		text = gsub(text, '([fkp])j$', '%1ç')
		text = gsub(text, '([bvgrm])j(#?)(.?)', function(prev, sep, succ)
			return (succ == '' or not match(succ, vowels)) and (prev .. 'ʝ' .. sep .. succ) or (prev .. 'j' .. sep .. succ) end)

		-- h-allophony
		local post_conv = {}
		for word in mw.text.gsplit(text, " ", true) do
			word = gsub(word, 'ch$', 'χχ')
			word = gsub(word, 'ch#', 'χχ#')
			word = gsub(word, '(.)c(h[eoö]z)$', '%1c#%2')
			word = gsub(word, vowels .. 'hh' .. vowels, '%1χχ%2')
			word = gsub(word, vowels .. 'cch' .. vowels, '%1χχ%2')
			word = gsub(word, 'ch', 'h')
		
			word = gsub(word, '(.?)(.?)h(.?)', function(penul, prev, succ)
				if prev == '' and penul ~= '' then
					prev, penul = penul, ''
				end
				if succ == '' or match(succ, '[bcdfghjklmnprstvwxyz]') then
					return penul .. prev .. 'χ' .. succ
				elseif match(succ, vowels) and (match(prev, vowels) and prev ~= succ) or (sonorant[prev] or sonorant[penul..prev]) then
					return penul .. prev .. 'ɦ' .. succ
				else
					return penul .. prev .. 'h' .. succ
				end end)
			
			table.insert(post_conv, word)
		end
		text = table.concat(post_conv, " ")

		-- adding hiatus 'j'
		text = gsub(text, non_i .. i_vowels, '%1j%2')
		text = gsub(text, i_vowels .. non_i, '%1j%2')

		-- converting to IPA symbols
		text = gsub(text, '([bcdfghjklmnprstvwxyz#]+)', function(cons_clus)
			if replace_cons[cons_clus] then
				return replace_cons[cons_clus]
			else
				for i = 1, 4 do
					for source, replace in pairs(replace_set[i]) do
						cons_clus = gsub(cons_clus, source, replace)
					end
				end
				return cons_clus
			end end)
	
		text = gsub(text, 'qu', 'kv')
		text = gsub(text, '.', replace_vowels)
	
		-- adding stress marks to words
		text = match(text, '^[^-]') and ('ˈ' .. gsub(text, ' ', ' ˈ')) or text
		
		-- word boundaries
		text = gsub(text, '[,-]', '')
	
		-- nasal assimilation
		text = gsub(text, 'n(n?)(#?)([kgcɟɲfvpbm])', function(repet, sep, cons)
			return nasal_assim[cons] .. (repet ~="" and nasal_assim[cons] or "") .. sep .. cons
		end)
		
		text = gsub(text, 'm(#?)([fv])', 'ɱ%1%2')

		local cons, opt_cons = '([lmnskgpbtdrfvɲɟχczʦʧʣʤṡʃʒjhŋɱɦχçʝ])', '([lmnskgpbtdrfvɲɟχczʦʧʣʤṡʃʒjhŋɱɦχçʝ]?)'
		text = gsub(text, '(.)#(.)', function(prev, succ)
			return (voicing_assim['devoicing'][prev] ~= succ and voicing_assim['voicing'][prev] ~= succ) and prev .. succ or prev .. '#' .. succ end)

		-- voicing and devoicing assimilations
		text = gsub(text, '([bvdzʣʒʤɟʝg]+)(#?[pftṡʦʃʧckh])', function(prev_cons, next_cons)
			return gsub(prev_cons, '.', voicing_assim['devoicing']) .. next_cons
		end)
	
		text = gsub(text, '([pftṡʦʃʧck]+)(#?[bdzʣʒʤɟg])', function(prev_cons, next_cons)
			return gsub(prev_cons, '.', voicing_assim['voicing']) .. next_cons
		end)
	
		-- geminate notation
		text = gsub(text, cons .. '%1%1', '%1ː')
		text = gsub(text, cons .. '(#?)%1', '%1ː%2')

		-- degemination when preceded or followed by a consonant
		text = gsub(text, opt_cons .. cons .. 'ː' .. opt_cons, function(prev_cons, gem_cons, next_cons)
			return prev_cons .. gem_cons .. (prev_cons .. next_cons ~= "" and '' or 'ː') .. next_cons end)
	
		-- back-replacing special characters
		text = gsub(text, '.', back_replace)
	
		-- making the indef. article 'a' liaise with the following word
		text = gsub(text, 'ˈɒ ', 'ɒ')

		-- making the indef. article 'az' liaise with the following word
		text = gsub(text, 'ˈɒz ', 'ɒz')

		-- making 'is' lose its accent and liaise with the preceding word (when followed by a space, to avoid other words starting with is- being involved)
		text = gsub(text, ' ˈiʃ ', 'iʃ ')

		-- making 'se' lose its accent and liaise with the preceding word (when followed by a space, to avoid other words starting with se- being involved)
		text = gsub(text, ' ˈʃɛ ', 'ʃɛ ')
		
		-- making 'sem' lose its accent and liaise with the preceding word (when followed by a space, to avoid other words starting with sem- being involved)
		text = gsub(text, ' ˈʃɛm ', 'ʃɛm ')

		-- making 'ha' lose its accent (when followed by a space, to avoid other words starting with ha- being involved)
		text = gsub(text, 'ˈhɒ ', 'hɒ ')

		-- making the conjunction 'vagy' lose its accent (no need to liaise in either direction)
		text = gsub(text, ' ˈvɒɟ ', 'vɒɟ ')

		-- making the conjunction 'és' lose its accent (no need to liaise in either direction)
		text = gsub(text, ' ˈeːʃ ', 'eːʃ ')

		-- removing the primary-stress mark if another such mark is manually supplied
		text = gsub(text, 'ˈˈ', 'ˈ')

		-- removing the primary-stress mark if a secondary-stress mark is manually supplied
		text = gsub(text, 'ˈˌ', 'ˌ')

		-- adding a space before primary-stress marks in case this space is missing
		text = gsub(text, 'ˈ', ' ˈ')

		-- adding a space before secondary-stress marks in case this space is missing
		text = gsub(text, 'ˌ', ' ˌ')
		
		-- replacing any double spaces (created by the previous command) with single ones
        text = gsub(text, '  ', ' ')
        
        return text
	
	-- 	table.insert(result, '[' .. text .. ']')
	-- end
	
	-- table.insert(result, 1, "hu")
	-- if (type(frame) == 'string') then
	-- 	return mw.ustring.sub(result[1], 2, mw.ustring.len(result[1]) - 1)
	-- else
	-- 	return frame:expandTemplate{ title = "IPA", args = result}
	-- end

end

return export