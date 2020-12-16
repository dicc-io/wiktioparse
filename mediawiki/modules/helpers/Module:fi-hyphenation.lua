local export = {}

local lang = "fi"
local sc = "Latn"

local vowels = "aeiouyåäö"
local vowel = "[" .. vowels .. "]"
local consonants = "bcdfghjklmnpqrstvwxzšžʔ*"
local consonant = "[" .. consonants .. "]"
 
-- orthographic symbols that signify separation of syllables
local sep_symbols = "-'’./ "
-- these signify that the next syllable is an "initial" syllable in a word
-- all symbols from here should also be in sep_symbols
local stressed_symbols = "-/ "
export.sep_symbols = sep_symbols

-- diphthongs and long vowels
-- in initial syllables
local vowel_sequences_initial = {
	"[aeouyäö]i",
	"[aoei]u",
	"[eiäö]y",
	"uo",
	"ie",
	"yö",
	"aa", "ee", "ii", "oo", "uu", "yy", "ää", "öö"
}
-- in non-initial syllables
-- further, diphthongs ending _u or _y are diphthongs only
-- in non-initial syllables if the syllable is open
local vowel_sequences_noninitial = {
	"[aeouyäö]i",
	"aa", "ee", "ii", "oo", "uu", "yy", "ää", "öö"
}
-- in non-initial *open* syllables, in addition to above
local vowel_sequences_noninitial_open = {
	"[aoei]u",
	"[eiäö]y"
}

-- allow_diphthongs_everywhere is only for backwards compatibility with {{fi-hyphenation}}
function export.generate_hyphenation(word, keep_sep_symbols, allow_diphthongs_everywhere)
	local res = {}
	local syllable = ""
	local pos = 1
	local found_vowel = false
	local initial_syllable = true
	
	while pos <= #word do
		if mw.ustring.find(mw.ustring.lower(word), "^" .. consonant .. vowel, pos) then
			-- CV: end current syllable if we have found a vowel
			if found_vowel then
				if syllable then
					table.insert(res, syllable)
					initial_syllable = false
				end
				
				found_vowel = false
				syllable = ""
			end
			syllable = syllable .. mw.ustring.sub(word, pos, pos)
			pos = pos + 1
		elseif mw.ustring.find(mw.ustring.lower(word), "^" .. consonant, pos) then
			-- C: continue
			syllable = syllable .. mw.ustring.sub(word, pos, pos)
			pos = pos + 1
		elseif mw.ustring.find(mw.ustring.lower(word), "^" .. vowel, pos) then
			if found_vowel then
				-- already found a vowel, end current syllable
				if syllable then
					table.insert(res, syllable)
					initial_syllable = false
				end
				syllable = ""
			end	
			found_vowel = true
			
			-- check for diphthongs or long vowels
			local vowel_sequences = (allow_diphthongs_everywhere or initial_syllable) and vowel_sequences_initial or vowel_sequences_noninitial
			local seq_ok = false
			for k, v in pairs(vowel_sequences) do
				if mw.ustring.find(mw.ustring.lower(word), "^" .. v, pos) then
					seq_ok = true
					break
				end
			end
			
			if not seq_ok and not initial_syllable then
				for k, v in pairs(vowel_sequences_noninitial_open) do
					if mw.ustring.find(mw.ustring.lower(word), "^" .. v .. "[^" .. consonants .. "]", pos) then
						seq_ok = true
						break
					end
				end
			end
			
			-- mw.logObject({word, pos, seq_ok, initial_syllable, vowel_sequences})
			
			if seq_ok then
				syllable = syllable .. mw.ustring.sub(word, pos, pos + 1)
				pos = pos + 2
			else
				syllable = syllable .. mw.ustring.sub(word, pos, pos)
				pos = pos + 1
			end
		elseif mw.ustring.find(mw.ustring.lower(word), "^[" .. sep_symbols .. "]", pos) then
			-- separates syllables
			if syllable then
				table.insert(res, syllable)
			end
			
			local sepchar = mw.ustring.sub(word, pos, pos)
			initial_syllable = mw.ustring.find(sepchar, "^[" .. stressed_symbols .. "]")
			syllable = (keep_sep_symbols == true or (type(keep_sep_symbols) == "string" and keep_sep_symbols:find(mw.ustring.sub(word, pos, pos)))) and sepchar or ""
			pos = pos + 1
			found_vowel = false
		else
			-- ?: continue
			syllable = syllable .. mw.ustring.sub(word, pos, pos)
			pos = pos + 1
		end
	end
	
	if syllable then
		table.insert(res, syllable)
	end
	
	return res
end

function export.hyphenation(frame)
	local title = mw.title.getCurrentTitle().text
	
	if type(frame) == "table" then
		local params = {
			[1] = {list = true, default = nil},
			
			["t"] = {},
			["title"] = {},
		}
		
		local args = require("Module:parameters").process(frame:getParent().args, params)
		
		hyphenation = args[1]
		title = args["t"] or (args["title"] or title)
	end
	
	if not hyphenation or #hyphenation < 1 then
		hyphenation = export.generate_hyphenation(title, false, true)
	end
	
	local text = require("Module:links").full_link({lang = require("Module:languages").getByCode(lang), alt = table.concat(hyphenation, "‧"), tr = "-"})
	return "Hyphenation: " .. text
end

return export