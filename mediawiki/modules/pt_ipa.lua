local export = {}

local gsub = mw.ustring.gsub
local match = mw.ustring.match
local gmatch = mw.ustring.gmatch
local split = mw.text.split

local tokens = {
	"a", "á", "â", "ã", "à",
	"b",
	"c", "ç", "ch",
	"d",
	"e", "é", "ê",
	"f",
	"g", "gu",
	"h",
	"i", "í",
	"j",
	"k",
	"l", "lh",
	"m",
	"n", "nh",
	"ó", "ô", "õ",
	"p",
	"qu",
	"r", "rr",
	"s", "ss",
	"t",
	"u", "ú",
	"v",
	"w",
	"x",
	"y",
	"z",
}

local digraphs = {
	"ch", "gu", "lh", "nh", "qu", "rr", "ss",
}

local function spelling_to_IPA(word)
	word = gsub(word,"ch","ʃ")
	word = gsub(word,"lh","ʎ")
	word = gsub(word,"nh","ɲ")
	word = gsub(word,"rr","ʁ")
	
	-- ç vs s vs ss
	word = gsub(word,"([aáâãàeéêiíoóôõuú])s([aáâãàeéêiíoóôõuú])","%1z%2")
	word = gsub(word,"ss","s")
	word = gsub(word,"ç","s")
	
	-- c vs g vs qu vs gu
	word = gsub(word,"([cgq]u?)(.?)",function (a,b)
		if a=="cu" then
			return "ku"..b
		end
		if a=="c" then
			if match(b,"[eéêií]") then
				return "s"..b
			else
				return "k"..b
			end
		elseif a=="g" then
			if match(b,"[eéêií]") then
				return "ʒ"..b
			else
				return "ɡ"..b -- U+0261 LATIN SMALL LETTER SCRIPT G
			end
		elseif a=="qu" then
			if match(b,"[eéêií]") then
				return "k"..b
			else
				return "kw"..b
			end
		elseif a=="gu" then
			if match(b,"[eéêií]") then
				return "ɡ"..b -- U+0261 LATIN SMALL LETTER SCRIPT G
			else
				return "ɡw"..b -- U+0261 LATIN SMALL LETTER SCRIPT G
			end
		else
			error("q not followed by u")
		end
	end)
	
	word = gsub(word,"j","ʒ")
	
	-- extract semivowels from diphthongs
	word = gsub(word,"([aáâãàeéêiíoóôõuú])i","%1j")
	word = gsub(word,"([aáâãàeéêiíoóôõuú])u","%1w")
	word = gsub(word,"u([aáâãàeéêiíoóôõuú])i","w%1")
	word = gsub(word,"(^[áâãàéêíóôõú])(%.+)i([jlmnrwz][s]?)$","%1%2í%3")
	word = gsub(word,"(^[áâãàéêíóôõú])(%.+)i([aeo][s]?)$","%1%2í%3")
	word = gsub(word,"(^[áâãàéêíóôõú])(%.+)i([jlmnrwz][s]?)$","%1%2í%3")
	word = gsub(word,"(^[áâãàéêíóôõú])(%.+)e([jlmnrwz][s]?)$","%1%2ê%3")
	word = gsub(word,"(^[áâãàéêíóôõú])(%.+)e([j]?[aeo][s]?)$","%1%2ê%3")
	
	-- syllabification
	word = gsub(word,"([aáâãàeéêiíoóôõuú])([^aáâãàeéêiíoóôõuú])","%1.%2")
	word = gsub(word,"([aáâãàeéêiíoóôõuú])([aáâãàeéêiíoóôõuú])","%1.%2")
	word = gsub(word,"([aáâãàeéêiíoóôõuú])%.([^aáâãàeéêiíoóôõuú.])([^aáâãàeéêiíoóôõuú.])","%1%2.%3")
	word = gsub(word,"%.([^aáâãàeéêiíoóôõuú.]+)$","%1")
	word = gsub(word,"([pbctdɡ])%.([lr])",".%1%2")
	
	-- r vs rr
	word = gsub(word,"%.r",".ʁ")
	word = gsub(word,"^r",".ʁ")
	word = gsub(word,"r","ɾ")
	
	-- s vs x vs z (/s/ vs /z/ vs /ʃ/ vs /ʒ/)
	word = gsub(word,"[szx](%.[ckpst])","ʃ%1")
	word = gsub(word,"[szx]$","ʃ")
	word = gsub(word,"[szx](%..)","ʒ%1")
	word = gsub(word,"x","ʃ")
	
	-- stress
	-- All words that I have found that contain more than one
	-- occurrence of [áâãeéêiíóôõú] are either acute+nasal or
	-- circumflex+nasal, with the nasal being ão (or õe)
	if match(word,"[áâãeéêiíóôõú]") then
		if match(word,"[áéíóúâêô]") then
			word = gsub(word,"%.([^.]+[áéíóúâêô])","ˈ%1")
		else
			word = gsub(word,"%.([^.]+[ãõ])","ˈ%1")
		end
	else
		if match(word,"[iu][sm]?$") or match(word,"[^aáâãàeéêiíoóôõuúms]$") then
			word = gsub(word,"%.([^.]+)$",function(a)
				return "ˈ" .. gsub(a,"[aeiou]",{
					["a"] = "á",
					["e"] = "é",
					["i"] = "í",
					["o"] = "ó",
					["u"] = "ú",
				})
			end)
		else
			word = gsub(word,"%.([^.]+%.[^.]+)$","ˈ%1")
		end
	end
	
	-- ão and õe
	word = gsub(word,"ão","ɐ̃w̃")
	word = gsub(word,"õe","õȷ̃")
	
	-- nasals
	word = gsub(word,"([aeéê])m$",{
		["a"] = "ɐ̃w̃",
		["e"] = "ɐ̃j̃",
		["é"] = "ɐ̃j̃",
		["ê"] = "ɐ̃j̃",
	})
	word = gsub(word,"[eé]mʃ$","ɐ̃j̃ʃ")
	word = gsub(word,"([aâeêiíoôuú])[mn]",{
		["a"] = "ɐ̃",
		["â"] = "ɐ̃",
		["e"] = "ẽ",
		["ê"] = "ẽ",
		["i"] = "ĩ",
		["í"] = "ĩ",
		["o"] = "õ",
		["ô"] = "õ",
		["u"] = "ũ",
		["ú"] = "ũ",
	})
	
	-- vowels
	word = gsub(word,"o$","u")
	word = gsub(word,"[aáâãàeéêiíoóôuú]",{
		["a"] = "ɐ",
		["á"] = "a",
		["â"] = "ɐ",
		["ã"] = "ɐ̃",
		["à"] = "a",
		["e"] = "ɨ",
		["é"] = "ɛ",
		["ê"] = "e",
		["i"] = "i",
		["í"] = "i",
		["o"] = "o",
		["ó"] = "ɔ",
		["ô"] = "o",
		["u"] = "u",
		["ú"] = "u",
	})
	
	word = gsub(word,"l%.","ɫ")
	word = gsub(word,"l$","ɫ")
	
	return word
end

function export.convertToIPA(word)
    return spelling_to_IPA(word)
end

function export.show(frame)
	local text = frame.args[1]
	text = gsub(text,"-","")
	text = split(text," ")
	for i,val in ipairs(text) do
		text[i] = spelling_to_IPA(val)
	end
	return table.concat(text," ")
end

return export