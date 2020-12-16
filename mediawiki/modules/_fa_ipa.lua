local export = {}
local rsubn = mw.ustring.gsub
local log = mw.log
local m_a = require("Module:accent_qualifier")
local m_IPA = require("Module:IPA")

local sc_fa = require("Module:scripts").getByCode("fa-Arab")
local sc_tg = require("Module:scripts").getByCode("Cyrl")
local lang_fa = require("Module:languages").getByCode("fa")
local lang_tg = require("Module:languages").getByCode("tg")

function export.show(frame)
    local args = frame:getParent().args

    local p, results_fa_cls, results_prs, results_fa, results_tg = {}, {}, {},
                                                                   {}, {}

    if args[1] then
        for index, item in ipairs(args) do
            table.insert(p, (item ~= "") and item or nil)
        end
    else
        if mw.title.getCurrentTitle().nsText == "Template" then
            p = {"wīkīwāža"}
        else
            error(
                'Please provide a Classical Persian romanisation in the first parameter of {{[[Template:fa-IPA/new|fa-IPA]]}}.')
        end
    end

    for _, word in ipairs(p) do
        table.insert(results_fa_cls,
                     {pron = "/" .. export.fa_cls_IPA(word) .. "/"})
        table.insert(results_prs, {pron = "/" .. export.prs_IPA(word) .. "/"})
        table.insert(results_fa, {pron = "/" .. export.fa_IPA(word) .. "/"})
        table.insert(results_tg, {pron = "/" .. export.tg_IPA(word) .. "/"})
    end

    local final_output = ""

    if mw.title.getCurrentTitle().nsText == "Template" then
        final_output = "* "
    end

    return final_output .. m_a.show({'Classical Persian'}) .. " " ..
               m_IPA.format_IPA_full(lang_fa, results_fa_cls) .. "\n* " ..
               m_a.show({'Dari Persian'}) .. " " ..
               m_IPA.format_IPA_full(lang_fa, results_prs) .. "\n* " ..
               m_a.show({'Iranian Persian'}) .. " " ..
               m_IPA.format_IPA_full(lang_fa, results_fa) .. "\n* " ..
               m_a.show({'Tajik'}) .. " " ..
               m_IPA.format_IPA_full(lang_fa, results_tg)
end

function export.show_tg(frame)
    local args = frame:getParent().args

    local p, results = {}, {}

    if args[1] then
        for index, item in ipairs(args) do
            table.insert(p, (item ~= "") and item or nil)
        end
    else
        if mw.title.getCurrentTitle().nsText == "Template" then
            p = {"wīkīluğat"}
        else
            error(
                'Please provide a Classical Persian romanisation in the first parameter of {{[[Template:tg-IPA/new|tg-IPA]]}}.')
        end
    end

    for _, word in ipairs(p) do
        table.insert(results, {pron = "/" .. export.tg_IPA(word) .. "/"})
    end

    local final_output = ""

    if mw.title.getCurrentTitle().nsText == "Template" then
        final_output = "* "
    end

    return final_output .. m_IPA.format_IPA_full(lang_tg, results)
end

local common_consonants = {
    ['j'] = 'd͡ʒ',
    ['\''] = 'ʔ',
    ['ḏ'] = 'z',
    ['ḍ'] = 'z',
    ['ğ'] = 'ɣ',
    ['ḥ'] = 'h',
    ['r'] = 'ɾ',
    ['ṣ'] = 's',
    ['š'] = 'ʃ',
    ['ṯ'] = 's',
    ['ṭ'] = 't',
    ['y'] = 'j',
    ['ž'] = 'ʒ',
    ['ẓ'] = 'z',
    ['č'] = 't͡ʃ',
    ["g"] = "ɡ"
}

local iranian_persian_short_vowels = {['a'] = 'æ', ['i'] = 'e', ['u'] = 'o'}

local iranian_persian_long_vowels = {
    ['ā'] = 'ɒː',
    ['ī'] = 'iː',
    ['ū'] = 'uː',
    ['ō'] = 'uː',
    ['ē'] = 'iː'
}

local iranian_persian_consonants = {['q'] = 'ɣ', ['w'] = 'v'}

local dari_persian_short_vowels = {['a'] = 'a', ['i'] = 'e', ['u'] = 'o'}

local dari_persian_long_vowels = {
    ['ā'] = 'ɒː',
    ['ī'] = 'iː',
    ['ū'] = 'uː',
    ['ō'] = 'oː',
    ['ē'] = 'eː'
}

local dari_persian_consonants = {['v'] = 'w'}

local tajik_short_vowels = {['a'] = 'a', ['i'] = 'ɪ', ['u'] = 'ʊ'}

local tajik_long_vowels = {
    ['ā'] = 'ɔ',
    ['ī'] = 'ɪ',
    ['ū'] = 'ʊ',
    ['ō'] = 'ɵ',
    ['ē'] = 'e'
}

local tajik_consonants = {['w'] = 'v'}

local classical_persian_short_vowels = {['a'] = 'a', ['i'] = 'i', ['u'] = 'u'}

local classical_persian_long_vowels = {
    ['ā'] = 'ɑː',
    ['ī'] = 'iː',
    ['ū'] = 'uː',
    ['ō'] = 'oː',
    ['ē'] = 'eː'
}

local classical_persian_consonants = {['v'] = 'w'}

local vowels = "aiuāīūēō"
local consonants = "[^" .. vowels .. "]"

function export.fa_IPA(text, do_debug)
    text = rsubn(text, "[-.]", " ")
    text = rsubn(text, "v", "w")
    -- Replace diphthong
    text = rsubn(text, "a([wy])()", function(semivowel, position)
        local consonant = mw.ustring.sub(text, position, position)
        if consonant == "" or consonant:find(consonants) then
            if semivowel == "w" then
                return "uw"
            else
                return "ey"
            end
        end
    end)
    -- Replace xwa with xu
    text = rsubn(text, "^xwa", "xu")
    -- Replace short vowels
    text = rsubn(text, ".", iranian_persian_short_vowels)
    -- Replace long vowels
    text = rsubn(text, ".", iranian_persian_long_vowels)
    -- Replace jj with dj
    text = rsubn(text, "jj", "dj")
    -- Replace čč with tč
    text = rsubn(text, "čč", "tč")
    -- Replace consonants
    text = rsubn(text, ".", common_consonants)
    text = rsubn(text, ".", iranian_persian_consonants)
    -- Replace final v with w
    text = rsubn(text, "ov()", function(position)
        local consonant = mw.ustring.sub(text, position, position)
        if consonant == "" or consonant == " " then return "ow" end
    end)
    -- Replace final æ with e
    text = rsubn(text, "æ()", function(position)
        local consonant = mw.ustring.sub(text, position, position)
        if consonant == "" or consonant == " " then return "e" end
    end)

    return text
end

function export.convertToIPA(word)
    return export.fa_IPA(word)
end

function export.prs_IPA(text, do_debug)
    text = rsubn(text, "[-.]", " ")
    text = rsubn(text, "v", "w")
    -- Replace xwa with xu
    text = rsubn(text, "^xwa", "xu")
    -- Replace short vowels
    text = rsubn(text, ".", dari_persian_short_vowels)
    -- Replace long vowels
    text = rsubn(text, ".", dari_persian_long_vowels)
    -- Replace jj with dj
    text = rsubn(text, "jj", "dj")
    -- Replace čč with tč
    text = rsubn(text, "čč", "tč")
    -- Replace consonants
    text = rsubn(text, ".", common_consonants)
    text = rsubn(text, ".", dari_persian_consonants)

    return text
end

function export.tg_IPA(text, do_debug)
    text = rsubn(text, "[-.]", " ")
    text = rsubn(text, "v", "w")
    -- Replace xwa with xu
    text = rsubn(text, "^xwa", "xu")
    -- Replace short vowels
    text = rsubn(text, ".", tajik_short_vowels)
    -- Replace long vowels
    text = rsubn(text, ".", tajik_long_vowels)
    -- Replace jj with dj
    text = rsubn(text, "jj", "dj")
    -- Replace čč with tč
    text = rsubn(text, "čč", "tč")
    -- Replace consonants
    text = rsubn(text, ".", common_consonants)
    text = rsubn(text, ".", tajik_consonants)

    return text
end

function export.fa_cls_IPA(text, do_debug)
    text = rsubn(text, "[-.]", " ")
    text = rsubn(text, "v", "w")
    -- Replace xwa with xʷa
    text = rsubn(text, "^xwa", "xʷa")
    -- Replace short vowels
    text = rsubn(text, ".", classical_persian_short_vowels)
    -- Replace long vowels
    text = rsubn(text, ".", classical_persian_long_vowels)
    -- Replace jj with dj
    text = rsubn(text, "jj", "dj")
    -- Replace čč with tč
    text = rsubn(text, "čč", "tč")
    -- Replace consonants
    text = rsubn(text, ".", common_consonants)
    text = rsubn(text, ".", classical_persian_consonants)

    return text
end

return export