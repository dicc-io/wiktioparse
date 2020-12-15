local export = {}

local lang = require("Module:languages").getByCode("eu")
local m_IPA = require("Module:IPA")
local m_a = require("Module:accent_qualifier")

local U = mw.ustring.char
local laminal = U(0x033B) -- for "z"
local apical = U(0x033A) -- for "s"

local simple_char = {
    ["g"] = "ɡ",
    ["x"] = "ʃ",
    ["r"] = "q",
    ["v"] = "b",
    ["ñ"] = "ɲ"
}

local multiple_char = {
    ["tx"] = "ć",
    ["tz"] = "ź",
    ["ts"] = "ś",
    ["tt"] = "c",
    ["dd"] = "ɟ"
}

local affricates = {["ć"] = "t͡ʃ", ["ś"] = "t͡s", ["ź"] = "t͡z"}

local V = "[aeiou]" -- vowel
local W = "[jw]"
local C = "[^aeiou.]" -- consonant

function export.convertToIPA(word)
    word = mw.ustring.lower(word)

    -- change symbols
    for pat, repl in pairs(multiple_char) do
        word = mw.ustring.gsub(word, pat, repl)
    end
    word = mw.ustring.gsub(word, '.', simple_char)
    word = mw.ustring.gsub(word, 'j', 'x')
    word = mw.ustring.gsub(word, 'n([pbm])', 'm%1')
	word = mw.ustring.gsub(word, 'y', 'j') --respelling for cases in which <j> is always /j/
	word = mw.ustring.gsub(word, 'kh', 'x') --for cases (usually loanwords) in which <j> is always /x/

    -- palatalised l and n
    word = mw.ustring.gsub(word, 'nh', '.n')
    word = mw.ustring.gsub(word, 'lh', '.l')
    word = mw.ustring.gsub(word, '(.?)in(.?)', function(before, after)
        if ('aeiou'):match(before) and ('aeiou'):match(after) then
            return before .. 'ɲ' .. after
        elseif ('aeiou'):match(after) then
            return before .. "iɲ" .. after
        end
    end)
    word = mw.ustring.gsub(word, '(.?)il(.?)', function(before, after)
        if ('aeiou'):match(before) and ('aeiou'):match(after) then
            return before .. 'ʎ' .. after
        elseif ('aeiou'):match(after) then
            return before .. "iʎ" .. after
        end
    end)

    -- trill in V-rr-V -> V-ɾ-V
    word = mw.ustring.gsub(word, '(.?)q(.?)', function(before, after)
        if ('aeiou'):match(after) and ('aeiou'):match(before) then
            return before .. 'ɾ' .. after
        end
    end)
    word = mw.ustring.gsub(word, '(.?)ɾ(.?)', function(before, after)
        if after == "" then return before .. 'r' .. after end
    end)
    word = mw.ustring.gsub(word, 'q', "r")
    word = mw.ustring.gsub(word, 'rr', "r")

    -- syllable division and glides
    for _ = 1, 2 do
        word = mw.ustring.gsub(word,
                               "(" .. V .. ")(" .. C .. W .. "?" .. V .. ")",
                               "%1.%2")
    end
    for _ = 1, 2 do
        word = mw.ustring.gsub(word, "(" .. V .. C .. ")(" .. C .. V .. ")",
                               "%1.%2")
    end
    for _ = 1, 2 do
        word = mw.ustring.gsub(word,
                               "(" .. V .. C .. ")(" .. C .. C .. V .. ")",
                               "%1.%2")
    end
    for _ = 1, 2 do
        word = mw.ustring.gsub(word,
                               "(" .. V .. C .. C .. ")(" .. C .. C .. V .. ")",
                               "%1.%2")
    end
    word = mw.ustring.gsub(word, "([pbktdɡ])%.([lr])", ".%1%2")
    word = mw.ustring.gsub(word, "(" .. C .. ")%.s(" .. C .. ")", "%1s.%2")
    word = mw.ustring.gsub(word, "([aeo])([aeo])", "%1.%2")
    word = mw.ustring.gsub(word, "([aeo])([iu])([aeo])", "%1%2.%3")
    word = mw.ustring.gsub(word, 'i([aeou])', 'j%1')
    word = mw.ustring.gsub(word, 'u([aeio])', 'w%1')

    -- affricates, s and z.
    word = mw.ustring.gsub(word, '.', affricates)
    word = mw.ustring.gsub(word, 's', "s" .. apical)
    word = mw.ustring.gsub(word, 'z', "s" .. laminal)

    -- optional h
    word = mw.ustring.gsub(word, 'h', "(ɦ)")

    return word
end

function export.show(frame)
    local args = frame:getParent().args
    local pagetitle = mw.title.getCurrentTitle().text

    local p, results = {}, {}

    if args[1] then
        for index, item in ipairs(args) do
            table.insert(p, (item ~= "") and item or nil)
        end
    else
        p = {pagetitle}
    end

    for _, word in ipairs(p) do
        table.insert(results, {pron = "/" .. export.pronunciation(word) .. "/"})
    end

    return m_a.show({'Standard Basque'}) .. " " .. m_IPA.format_IPA_full(lang, results)
end

return export