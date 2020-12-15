local export = {}

local m_params = require("Module:parameters")
local m_IPA = require("Module:IPA")
local m_syllables = require("Module:syllables")
local m_links = require("Module:links")
local m_script_utils = require("Module:script_utilities")

local lang = require("Module:languages").getByCode("sk")
local sc = require("Module:scripts").getByCode("Latn")

local sub = mw.ustring.sub
local gsub = mw.ustring.gsub
local find = mw.ustring.find
local match = mw.ustring.match
local gmatch = mw.ustring.gmatch

local U = mw.ustring.char
local long = "ː"
local nonsyllabic = U(0x32F)	-- inverted breve below
local syllabic = U(0x0329)
local tie = U(0x361)			-- combining double inverted breve
local primary_stress = "ˈ"
local secondary_stress = "ˌ"

local data = {
	["á"] = "a" .. long,
	["ä"] = "æ",
	["c"] = "t" .. tie .. "s",
	["č"] = "t" .. tie .. "ʃ",
	["ď"] = "ɟ",
	["dz"] = "d" .. tie .. "z",
	["dž"] = "d" .. tie .. "ʒ",
	["é"] = "e" .. long,
	["g"] = "ɡ",
	["h"] = "ɦ",
	["ch"] = "x",
	["í"] = "i" .. long,
	["ĺ"] = "l" .. syllabic .. long,
	["ľ"] = "ʎ",
	["ň"] = "ɲ",
	["ó"] = "o" .. long,
	["ô"] = "u̯o",
	["ŕ"] = "r" .. syllabic .. long,
	["š"] = "ʃ",
	["ť"] = "c",
	["ú"] = "u" .. long,
	["y"] = "i",
	["ý"] = "i" .. long,
	["ž"] = "ʒ",
	["ia"] = "i" .. nonsyllabic .. "a",
	["ie"] = "i" .. nonsyllabic .. "e",
	["iu"] = "i" .. nonsyllabic .. "u",
	["\""] = primary_stress,
	["%"] = secondary_stress,
}

-- Add data["a"] = "a", data["b"] = "b", etc.
for character in gmatch("abdefijklmnoprstuvz ", ".") do
	data[character] = character
end

-- [==[			Phonological rules		]==]

--[[
This is used to replace multiple-character sounds
with numbers, which makes it easier to process them.	]]

local multiple_char = {
	"t" .. tie .. "s",	"t" .. tie .. "ʃ", "d" .. tie .. "z",	"d" .. tie .. "ʒ",
}

local singlechar = {}
for number, character in pairs(multiple_char) do
	singlechar[character] = tostring(number)
end

local voiceless	= { "p", "t", "c", "k", "f", "s", "ʃ", "x", "1", "2", }
local voiced	= { "b", "d", "ɟ", "ɡ", "v", "z", "ʒ", "ɦ", "3", "4", }
local sonorants = { "m", "n", "ɲ", "r", "l", "ʎ", "j", }

local features = {}
local indices = {}
for i, consonant in pairs(voiceless) do
	if not features[consonant] then
		features[consonant] = {}
	end
	features[consonant]["voicing"] = false
	indices[consonant] = i
end

for i, consonant in pairs (voiced) do
	if not features[consonant] then
		features[consonant] = {}
	end
	features[consonant]["voicing"] = true
	indices[consonant] = i
end

local function devoice_finally(IPA)
	local voiced_obstruent = "[" .. table.concat(voiced) .. "]"
	
	local final_voiced_obstruent = match(IPA, voiced_obstruent .. "+$") or match(IPA, voiced_obstruent .. "+%s")
	
	if final_voiced_obstruent then
		local replacement = {}
		
		local length = mw.ustring.len(final_voiced_obstruent)
		
		for i = 1, length do
			local consonant = sub(final_voiced_obstruent, i, i)
			local index = indices[consonant]
			local devoiced = voiceless[index]
			
			table.insert(replacement, devoiced)
		end
		
		replacement = table.concat(replacement)
		-- This will cause problems if the same consonant cluster occurs elsewhere in the term.
		IPA = gsub(IPA, final_voiced_obstruent, replacement)
	end
	
	return IPA
end

local function syllabicize_sonorants(IPA)
	local sonorant = gsub("[" .. table.concat(sonorants) .. "]", "[ɲʎj]", "") -- all except ɲ and ʎ and j
	local obstruent = "[" .. table.concat(voiced) .. table.concat(voiceless) .. "]"
	local consonant = "[" .. gsub(sonorant .. obstruent, "[%[%]]", "") .. "]"
	
	-- between a consonant and an obstruent
	IPA = gsub(IPA, "(" .. consonant .. sonorant .. ")(" .. obstruent .. ")", "%1" .. syllabic .. "%2")
	-- at the beginning of a word before an obstruent
	IPA = gsub(IPA, "^(" .. sonorant .. ")(" .. obstruent .. ")", "%1" .. syllabic .. "%2")
	-- at the end of a word after an obstruent
	IPA = gsub(IPA, "(" .. obstruent .. sonorant .. ")$", "%1" .. syllabic)
	
	return IPA
end

local function add_stress(IPA)
	local syllable_count = m_syllables.getVowels(IPA, lang)
	
	if not syllable_count then
		-- words like “čln” or “v” contain no designated vowels, yet they are
		-- valid Slovak words
		-- error("Could not count syllables of " .. IPA)
		syllable_count = 1
	end
	
	if syllable_count > 1 and not find(IPA, " ") then
		IPA = primary_stress .. IPA
	end
	
	return IPA
end

local function apply_rules(IPA)
	-- Replace multiple-character units with numbers.
	for sound, character in pairs(singlechar) do
		IPA = gsub(IPA, sound, character)
	end
	
	IPA = devoice_finally(IPA)
	IPA = syllabicize_sonorants(IPA)
	IPA = add_stress(IPA)
	
	-- Change double to single consonants.
	local consonant = "[" .. table.concat(sonorants) .. table.concat(voiceless) .. table.concat(voiced) .. "]"
	IPA = gsub(IPA, "(" .. consonant .. ")%1", "%1")
	
	-- Replace numbers with multiple-character units.
	for sound, character in pairs(singlechar) do
		IPA = gsub(IPA, character, sound)
	end
	
	return IPA
end

function export.convertToIPA(term)
	local IPA = {}
	local transcription = mw.ustring.lower(term)
	
	local working_string = transcription
	
	while mw.ustring.len(working_string) > 0 do
		local IPA_letter
		
		local letter = sub(working_string, 1, 1)
		local twoletters = sub(working_string, 1, 2) or ""
		
		if data[twoletters] then
			IPA_letter = data[twoletters]
			working_string = sub(working_string, 3)
		else
			IPA_letter = data[letter] or error('The letter "' .. tostring(letter) .. '" is not a member of the Slovak alphabet.')
			working_string = sub(working_string, 2)
		end
		
		table.insert(IPA, IPA_letter)
	end
	
	IPA = table.concat(IPA)
	IPA = apply_rules(IPA)
	
	return IPA--, transcription
end

function export.show(frame)
	local params = {
		[1] = {}
	}
	
	local title = mw.title.getCurrentTitle()
	
	local args = m_params.process(frame:getParent().args, params)
	local term = args[1] or title.nsText == "Template" and "príklad" or title.text
	
	local IPA = export.toIPA(term)
	
	IPA = "[" .. IPA .. "]"
	IPA = m_IPA.format_IPA_full(lang, { { pron = IPA } } )
	
	return IPA
end

function export.example(frame)
	local params = {
		[1] = { required = true },
		["term"] = {}
	}
	
	local args = m_params.process(frame.args, params)
	local term = args["term"] or args[1]
	local transcribable = args[1]
	
	local IPA, transcribable = export.toIPA(transcribable)
	
	IPA = "[" .. IPA .. "]"
	IPA = m_IPA.format_IPA_full(lang, { { pron = IPA } } )
	
	link = m_links.full_link( { term = term, lang = lang, sc = sc }, "term" )
	
	return link .. ( term ~= transcribable and ( " (" .. m_script_utils.tag_text(transcribable, lang, nil, "term") .. ") &mdash; " ) or " &mdash; " ) .. IPA
end

return export