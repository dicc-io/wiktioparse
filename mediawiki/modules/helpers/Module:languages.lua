local export = {}

--[=[	This function checks for things that could plausibly be a language code:
		two or three lowercase letters, two or three groups of three lowercase
		letters with hyphens between them. If such a pattern is not found,
		it is likely the editor simply forgot to enter a language code. ]=]

function export.err(langCode, param, text, template_tag, not_real_lang)
	local ordinals = {
		"first", "second", "third", "fourth", "fifth", "sixth",
		"seventh", "eighth", "ninth", "tenth", "eleventh", "twelfth",
		"thirteenth", "fourteenth", "fifteenth", "sixteenth", "seventeenth",
		"eighteenth", "nineteenth", "twentieth"
	}
	
	text = text or "language code"
	
	if not template_tag then
		template_tag = ""
	else
		if type(template_tag) ~= "string" then
			template_tag = template_tag()
		end
		template_tag = " (Original template: " .. template_tag .. ")"
	end
	local paramType = type(param)
	if paramType == "number" then
		ordinal = ordinals[param]
		param = ordinal .. ' parameter'
	elseif paramType == "string" then
		param = 'parameter "' .. param .. '"'
	else
		error("The parameter name is "
				.. (paramType == "table" and "a table" or tostring(param))
				.. ", but it should be a number or a string." .. template_tag, 2)
	end
	
	-- Can use string.find because language codes only contain ASCII.
	if not langCode or langCode == "" then
		error("The " .. param .. " (" .. text .. ") is missing." .. template_tag, 2)
	elseif not_real_lang or langCode:find("^%l%l%l?$")
			or langCode:find("^%l%l%l%-%l%l%l$")
			or langCode:find("^%l%l%l%-%l%l%l%-%l%l%l$") then
		error("The " .. text .. " \"" .. langCode .. "\" is not valid." .. template_tag, 2)
	else
		error("Please enter a " .. text .. " in the " .. param .. ". The value \"" .. langCode .. "\" is not valid." .. template_tag, 2)
	end
end

local function do_entry_name_or_sort_key_replacements(text, replacements)
	if replacements.from then
		for i, from in ipairs(replacements.from) do
			local to = replacements.to[i] or ""
			text = mw.ustring.gsub(text, from, to)
		end
	end
	
	if replacements.remove_diacritics then
		text = mw.ustring.toNFD(text)
		text = mw.ustring.gsub(text,
			'[' .. replacements.remove_diacritics .. ']',
			'')
		text = mw.ustring.toNFC(text)
	end
	
	return text
end

local Language = {}

function Language:getCode()
	return self._code
end


function Language:getCanonicalName()
	return self._rawData[1] or self._rawData.canonicalName
end


function Language:getDisplayForm()
	return self:getCanonicalName()
end


function Language:getOtherNames(onlyOtherNames)
	return require("Module:language-like").getOtherNames(self, onlyOtherNames)
end


function Language:getAliases()
	return self._rawData.aliases or {}
end


function Language:getVarieties(flatten)
	return require("Module:language-like").getVarieties(self, flatten)
end


function Language:getType()
	return self._rawData.type or "regular"
end


function Language:getWikimediaLanguages()
	if not self._wikimediaLanguageObjects then
		local m_wikimedia_languages = require("Module:wikimedia languages")
		self._wikimediaLanguageObjects = {}
		local wikimedia_codes = self._rawData.wikimedia_codes or { self._code }
		
		for _, wlangcode in ipairs(wikimedia_codes) do
			table.insert(self._wikimediaLanguageObjects, m_wikimedia_languages.getByCode(wlangcode))
		end
	end
	
	return self._wikimediaLanguageObjects
end

function Language:getWikipediaArticle()
	if self._rawData.wikipedia_article then
		return self._rawData.wikipedia_article 
	elseif self._wikipedia_article then
		return self._wikipedia_article
	elseif self:getWikidataItem() and mw.wikibase then
		self._wikipedia_article = mw.wikibase.sitelink(self:getWikidataItem(), 'enwiki')
	end
	if not self._wikipedia_article then
		self._wikipedia_article = mw.ustring.gsub(self:getCategoryName(), "Creole language", "Creole")
	end
	return self._wikipedia_article
end

function Language:makeWikipediaLink()
	return "[[w:" .. self:getWikipediaArticle() .. "|" .. self:getCanonicalName() .. "]]"
end

function Language:getWikidataItem()
	return self._rawData[2] or self._rawData.wikidata_item
end

function Language:getScripts()
	if not self._scriptObjects then
		local m_scripts = require("Module:scripts")
		self._scriptObjects = {}
		
		for _, sc in ipairs(self._rawData.scripts or { "None" }) do
			table.insert(self._scriptObjects, m_scripts.getByCode(sc))
		end
	end
	
	return self._scriptObjects
end

function Language:getScriptCodes()
	return self._rawData.scripts or { "None" }
end

function Language:getFamily()
	if self._familyObject then
		return self._familyObject
	end
		
	local family = self._rawData[3] or self._rawData.family 
	if family then
		self._familyObject = require("Module:families").getByCode(family)
	end
	
	return self._familyObject
end


function Language:getAncestors()
	if not self._ancestorObjects then
		self._ancestorObjects = {}
		
		if self._rawData.ancestors then
			for _, ancestor in ipairs(self._rawData.ancestors) do
				table.insert(self._ancestorObjects, export.getByCode(ancestor) or require("Module:etymology languages").getByCode(ancestor))
			end
		else
			local fam = self:getFamily()
			local protoLang = fam and fam:getProtoLanguage() or nil
			
			-- For the case where the current language is the proto-language
			-- of its family, we need to step up a level higher right from the start.
			if protoLang and protoLang:getCode() == self:getCode() then
				fam = fam:getFamily()
				protoLang = fam and fam:getProtoLanguage() or nil
			end
			
			while not protoLang and not (not fam or fam:getCode() == "qfa-not") do
				fam = fam:getFamily()
				protoLang = fam and fam:getProtoLanguage() or nil
			end
			
			table.insert(self._ancestorObjects, protoLang)
		end
	end
	
	return self._ancestorObjects
end

local function iterateOverAncestorTree(node, func)
	for _, ancestor in ipairs(node:getAncestors()) do
		if ancestor then
			local ret = func(ancestor) or iterateOverAncestorTree(ancestor, func)
			if ret then
				return ret
			end
		end
	end
end

function Language:getAncestorChain()
	if not self._ancestorChain then
		self._ancestorChain = {}
		local step = #self:getAncestors() == 1 and self:getAncestors()[1] or nil
		
		while step do
			table.insert(self._ancestorChain, 1, step)
			step = #step:getAncestors() == 1 and step:getAncestors()[1] or nil
		end
	end
	
	return self._ancestorChain
end


function Language:hasAncestor(otherlang)
	local function compare(ancestor)
		return ancestor:getCode() == otherlang:getCode()
	end
	
	return iterateOverAncestorTree(self, compare) or false
end


function Language:getCategoryName()
	local name = self:getCanonicalName()
	
	-- If the name already has "language" in it, don't add it.
	if name:find("[Ll]anguage$") then
		return name
	else
		return name .. " language"
	end
end


function Language:makeCategoryLink()
	return "[[:Category:" .. self:getCategoryName() .. "|" .. self:getCanonicalName() .. "]]"
end


function Language:getStandardCharacters()
	return self._rawData.standardChars
end


function Language:makeEntryName(text)
	text = mw.ustring.match(text, "^[¿¡]?(.-[^%s%p].-)%s*[؟?!;՛՜ ՞ ՟？！︖︕।॥။၊་།]?$") or text
	
	if self:getCode() == "ar" then
		local U = mw.ustring.char
		local taTwiil = U(0x640)
		local waSla = U(0x671)
		-- diacritics ordinarily removed by entry_name replacements
		local Arabic_diacritics = U(0x64B, 0x64C, 0x64D, 0x64E, 0x64F, 0x650, 0x651, 0x652, 0x670)
		
		if text == waSla or mw.ustring.find(text, "^" .. taTwiil .. "?[" .. Arabic_diacritics .. "]" .. "$") then
			return text
		end
	end
	
	if type(self._rawData.entry_name) == "table" then
		text = do_entry_name_or_sort_key_replacements(text, self._rawData.entry_name)
	end
	
	return text
end


-- Add to data tables?
local has_dotted_undotted_i = {
	["az"] = true,
	["crh"] = true,
	["gag"] = true,
	["kaa"] = true,
	["tt"] = true,
	["tr"] = true,
	["zza"] = true,
}

function Language:makeSortKey(name, sc)
	if has_dotted_undotted_i[self:getCode()] then
		name = name:gsub("I", "ı")
	end
	
	name = mw.ustring.lower(name)
	
	-- Remove initial hyphens and *
	local hyphens_regex = "^[-־ـ*]+(.)"
	name = mw.ustring.gsub(name, hyphens_regex, "%1")
	
	-- If there are language-specific rules to generate the key, use those
	if type(self._rawData.sort_key) == "table" then
		name = do_entry_name_or_sort_key_replacements(name, self._rawData.sort_key)
	elseif type(self._rawData.sort_key) == "string" then
		name = require("Module:" .. self._rawData.sort_key).makeSortKey(name, self:getCode(), sc and sc:getCode())
	end
	
	-- Remove parentheses, as long as they are either preceded or followed by something
	name = mw.ustring.gsub(name, "(.)[()]+", "%1")
	name = mw.ustring.gsub(name, "[()]+(.)", "%1")
	
	if has_dotted_undotted_i[self:getCode()] then
		name = name:gsub("i", "İ")
	end
	
	return mw.ustring.upper(name)
end

function Language:overrideManualTranslit()
	if self._rawData.override_translit then
		return true
	else
		return false
	end
end


function Language:transliterate(text, sc, module_override)
	if not ((module_override or self._rawData.translit_module) and text) then
		return nil
	end
	
	if module_override then
		require("Module:debug").track("module_override")
	end
	
	return require("Module:" .. (module_override or self._rawData.translit_module)).tr(text, self:getCode(), sc and sc:getCode() or nil)
end

function Language:hasTranslit()
	return self._rawData.translit_module and true or false
end


function Language:link_tr()
	return self._rawData.link_tr and true or false
end


function Language:toJSON()
	local entryNamePatterns = nil
	local entryNameRemoveDiacritics = nil
	
	if self._rawData.entry_name then
		entryNameRemoveDiacritics = self._rawData.entry_name.remove_diacritics
		if self._rawData.entry_name.from then
			entryNamePatterns = {}
			for i, from in ipairs(self._rawData.entry_name.from) do
				local to = self._rawData.entry_name.to[i] or ""
				table.insert(entryNamePatterns, { from = from, to = to })
			end
		end
	end
	
	local ret = {
		ancestors = self._rawData.ancestors,
		canonicalName = self:getCanonicalName(),
		categoryName = self:getCategoryName(),
		code = self._code,
		entryNamePatterns = entryNamePatterns,
		entryNameRemoveDiacritics = entryNameRemoveDiacritics,
		family = self._rawData[3] or self._rawData.family,
		otherNames = self:getOtherNames(true),
		aliases = self:getAliases(),
		varieties = self:getVarieties(),
		scripts = self._rawData.scripts,
		type = self:getType(),
		wikimediaLanguages = self._rawData.wikimedia_codes,
		wikidataItem = self:getWikidataItem(),
	}
	
	return require("Module:JSON").toJSON(ret)
end


-- Do NOT use this method!
-- All uses should be pre-approved on the talk page!
function Language:getRawData()
	return self._rawData
end

Language.__index = Language


function export.getDataModuleName(code)
	if code:find("^%l%l$") then
		return "languages/data2"
	elseif code:find("^%l%l%l$") then
		local prefix = code:sub(1, 1)
		return "languages/data3/" .. prefix
	elseif code:find("^[%l-]+$") then
		return "languages/datax"
	else
		return nil
	end
end


local function getRawLanguageData(code)
	local modulename = export.getDataModuleName(code)
	return modulename and mw.loadData("Module:" .. modulename)[code] or nil
end


function export.makeObject(code, data)
	if data and data.deprecated then
		require("Module:debug").track {
			"languages/deprecated",
			"languages/deprecated/" .. code
		}
	end
	
	return data and setmetatable({ _rawData = data, _code = code }, Language) or nil
end


function export.getByCode(code, paramForError, allowEtymLang, allowFamily)
	if type(code) ~= "string" then
		error("The function getByCode expects a string as its first argument, but received " .. (code == nil and "nil" or "a " .. type(code)) .. ".")
	end
	
	local retval = export.makeObject(code, getRawLanguageData(code))
	if not retval and allowEtymLang then
		retval = require("Module:etymology languages").getByCode(code)
	end
	if not retval and allowFamily then
		retval = require("Module:families").getByCode(code)
	end
	if not retval and paramForError then
		local codetext = nil
		if allowEtymLang and allowFamily then
			codetext = "language, etymology language or family code"
		elseif allowEtymLang then
			codetext = "language or etymology language code"
		elseif allowFamily then
			codetext = "language or family code"
		else
			codetext = "language code"
		end
		if paramForError == true then
			error("The " .. codetext .. " \"" .. code .. "\" is not valid.")
		else
			export.err(code, paramForError, codetext)
		end
	end
	return retval
end


function export.getByName(name, errorIfInvalid)
	local byName = mw.loadData("Module:languages/by name")
	local code = byName.all and byName.all[name] or byName[name]
	
	if not code then
		if errorIfInvalid then
			error("The language name \"" .. name .. "\" is not valid.")
		else
			return nil
		end
	end
	
	return export.makeObject(code, getRawLanguageData(code))
end

function export.getByCanonicalName(name, errorIfInvalid, allowEtymLang, allowFamily)
	local byName = mw.loadData("Module:languages/canonical names")
	local code = byName and byName[name]

	local retval = code and export.makeObject(code, getRawLanguageData(code)) or nil
	if not retval and allowEtymLang then
		retval = require("Module:etymology languages").getByCanonicalName(name)
	end
	if not retval and allowFamily then
		local famname = name:match("^(.*) languages$")
		famname = famname or name
		retval = require("Module:families").getByCanonicalName(famname)
	end
	if not retval and errorIfInvalid then
		local text
		if allowEtymLang and allowFamily then
			text = "language, etymology language or family name"
		elseif allowEtymLang then
			text = "language or etymology language name"
		elseif allowFamily then
			text = "language or family name"
		else
			text = "language name"
		end
		error("The " .. text .. " \"" .. name .. "\" is not valid.")
	end
	return retval
end

function export.iterateAll()
	mw.incrementExpensiveFunctionCount()
	local m_data = mw.loadData("Module:languages/alldata")
	local func, t, var = pairs(m_data)
	
	return function()
		local code, data = func(t, var)
		return export.makeObject(code, data)
	end
end

--[[	If language is an etymology language, iterates through parent languages
		until it finds a non-etymology language. ]]
function export.getNonEtymological(lang)
	while lang:getType() == "etymology language" do
		local parentCode = lang:getParentCode()
		lang = export.getByCode(parentCode)
			or require("Module:etymology languages").getByCode(parentCode)
			or require("Module:families").getByCode(parentCode)
	end
	
	return lang
end

return export