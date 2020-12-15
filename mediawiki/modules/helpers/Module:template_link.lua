local export = {}
local date_and_time				= "mw:Help:Magic words#Date and time"
local technical_metadata		= "mw:Help:Magic words#Technical metadata"
local tech_meta_another_page	= "mw:Help:Magic words#Technical metadata of another page"
local page_names				= "mw:Help:Magic words#Page names"
local namespaces				= "mw:Help:Magic words#Namespaces"
local formatting				= "mw:Help:Magic words#Formatting"
local URL_data					= "mw:Help:Magic words#URL data"
local localization				= "mw:Help:Magic words#Localization"
local miscellaneous				= "mw:Help:Magic words#Miscellaneous"
local parser_functions_link		= "mw:Help:Extension:ParserFunctions"
local LST						= "mw:Extension:Labeled Section Transclusion"

local variables_nullary = {
	["CURRENTYEAR"        ] = date_and_time;
	["CURRENTMONTH"       ] = date_and_time;
	["CURRENTMONTH1"      ] = date_and_time; -- undocumented
	["CURRENTMONTH2"      ] = date_and_time; -- undocumented
	["CURRENTMONTHNAME"   ] = date_and_time;
	["CURRENTMONTHNAMEGEN"] = date_and_time;
	["CURRENTMONTHABBREV" ] = date_and_time;
	["CURRENTDAY"         ] = date_and_time;
	["CURRENTDAY2"        ] = date_and_time;
	["CURRENTDOW"         ] = date_and_time;
	["CURRENTDAYNAME"     ] = date_and_time;
	["CURRENTTIME"        ] = date_and_time;
	["CURRENTHOUR"        ] = date_and_time;
	["CURRENTWEEK"        ] = date_and_time;
	["CURRENTTIMESTAMP"   ] = date_and_time;

	["LOCALYEAR"          ] = date_and_time;
	["LOCALMONTH"         ] = date_and_time;
	["LOCALMONTH1"        ] = date_and_time; -- undocumented
	["LOCALMONTH2"        ] = date_and_time; -- undocumented
	["LOCALMONTHNAME"     ] = date_and_time;
	["LOCALMONTHNAMEGEN"  ] = date_and_time;
	["LOCALMONTHABBREV"   ] = date_and_time;
	["LOCALDAY"           ] = date_and_time;
	["LOCALDAY2"          ] = date_and_time;
	["LOCALDOW"           ] = date_and_time;
	["LOCALDAYNAME"       ] = date_and_time;
	["LOCALTIME"          ] = date_and_time;
	["LOCALHOUR"          ] = date_and_time;
	["LOCALWEEK"          ] = date_and_time;
	["LOCALTIMESTAMP"     ] = date_and_time;

	["SITENAME"           ] = technical_metadata;
	["SERVER"             ] = technical_metadata;
	["SERVERNAME"         ] = technical_metadata;
	["DIRMARK"            ] = technical_metadata;
	["DIRECTIONMARK"      ] = technical_metadata;
	["ARTICLEPATH"        ] = technical_metadata; -- undocumented
	["SCRIPTPATH"         ] = technical_metadata;
	["STYLEPATH"          ] = technical_metadata;
	["CURRENTVERSION"     ] = technical_metadata;
	["CONTENTLANGUAGE"    ] = technical_metadata;
	["CONTENTLANG"        ] = technical_metadata;

	["PAGEID"             ] = technical_metadata;
	["CASCADINGSOURCES"   ] = technical_metadata;
	
	["REVISIONID"         ] = technical_metadata;
	["REVISIONDAY"        ] = technical_metadata;
	["REVISIONDAY2"       ] = technical_metadata;
	["REVISIONMONTH"      ] = technical_metadata;
	["REVISIONMONTH1"     ] = technical_metadata;
	["REVISIONYEAR"       ] = technical_metadata;
	["REVISIONTIMESTAMP"  ] = technical_metadata;
	["REVISIONUSER"       ] = technical_metadata;
	["REVISIONSIZE"       ] = technical_metadata;
	
	["NUMBEROFPAGES"      ] = technical_metadata;
	["NUMBEROFARTICLES"   ] = technical_metadata;
	["NUMBEROFFILES"      ] = technical_metadata;
	["NUMBEROFEDITS"      ] = technical_metadata;
	["NUMBEROFVIEWS"      ] = technical_metadata;
	["NUMBEROFUSERS"      ] = technical_metadata;
	["NUMBEROFADMINS"     ] = technical_metadata;
	["NUMBEROFACTIVEUSERS"] = technical_metadata;
	
	["FULLPAGENAME"       ] = page_names;
	["PAGENAME"           ] = page_names;
	["BASEPAGENAME"       ] = page_names;
	["SUBPAGENAME"        ] = page_names;
	["SUBJECTPAGENAME"    ] = page_names;
	["ARTICLEPAGENAME"    ] = page_names;
	["TALKPAGENAME"       ] = page_names;
	["ROOTPAGENAME"       ] = page_names; -- undocumented

	["FULLPAGENAMEE"      ] = page_names;
	["PAGENAMEE"          ] = page_names;
	["BASEPAGENAMEE"      ] = page_names;
	["SUBPAGENAMEE"       ] = page_names;
	["SUBJECTPAGENAMEE"   ] = page_names;
	["ARTICLEPAGENAMEE"   ] = page_names;
	["TALKPAGENAMEE"      ] = page_names;
	["ROOTPAGENAMEE"      ] = page_names; -- undocumented

	["NAMESPACE"          ] = namespaces;
	["NAMESPACENUMBER"    ] = namespaces;
	["SUBJECTSPACE"       ] = namespaces;
	["ARTICLESPACE"       ] = namespaces;
	["TALKSPACE"          ] = namespaces;

	["NAMESPACEE"         ] = namespaces;
	["SUBJECTSPACEE"      ] = namespaces;
	["TALKSPACEE"         ] = namespaces;

	["!"                  ] = "mw:Help:Magic words#Other";
}

local variables_nonnullary = {
	["PROTECTIONLEVEL"    ] = technical_metadata;

	["DISPLAYTITLE"       ] = technical_metadata;
	["DEFAULTSORT"        ] = technical_metadata;

	["PAGESINCATEGORY"    ] = technical_metadata;
	["PAGESINCAT"         ] = technical_metadata;
	
	["NUMBERINGROUP"      ] = technical_metadata;
	["PAGESINNS"          ] = technical_metadata;
	["PAGESINNAMESPACE"   ] = technical_metadata;

	["FULLPAGENAME"       ] = page_names;
	["PAGENAME"           ] = page_names;
	["BASEPAGENAME"       ] = page_names;
	["SUBPAGENAME"        ] = page_names;
	["SUBJECTPAGENAME"    ] = page_names;
	["ARTICLEPAGENAME"    ] = page_names;
	["TALKPAGENAME"       ] = page_names;
	["ROOTPAGENAME"       ] = page_names; -- undocumented

	["FULLPAGENAMEE"      ] = page_names;
	["PAGENAMEE"          ] = page_names;
	["BASEPAGENAMEE"      ] = page_names;
	["SUBPAGENAMEE"       ] = page_names;
	["SUBJECTPAGENAMEE"   ] = page_names;
	["ARTICLEPAGENAMEE"   ] = page_names;
	["TALKPAGENAMEE"      ] = page_names;
	["ROOTPAGENAMEE"      ] = page_names; -- undocumented

	["NAMESPACE"          ] = namespaces;
	["NAMESPACENUMBER"    ] = namespaces;
	["SUBJECTSPACE"       ] = namespaces;
	["ARTICLESPACE"       ] = namespaces;
	["TALKSPACE"          ] = namespaces;

	["NAMESPACEE"         ] = namespaces;
	["SUBJECTSPACEE"      ] = namespaces;
	["TALKSPACEE"         ] = namespaces;

	["PAGEID"             ] = tech_meta_another_page;
	["PAGESIZE"           ] = tech_meta_another_page;
	["PROTECTIONLEVEL"    ] = tech_meta_another_page;
	["CASCADINGSOURCES"   ] = tech_meta_another_page;
	["REVISIONID"         ] = tech_meta_another_page;
	["REVISIONDAY"        ] = tech_meta_another_page;
	["REVISIONDAY2"       ] = tech_meta_another_page;
	["REVISIONMONTH"      ] = tech_meta_another_page;
	["REVISIONMONTH1"     ] = tech_meta_another_page;
	["REVISIONYEAR"       ] = tech_meta_another_page;
	["REVISIONTIMESTAMP"  ] = tech_meta_another_page;
	["REVISIONUSER"       ] = tech_meta_another_page;
}

local parser_functions = {
	-- built-ins
	["localurl"     ] = URL_data;
	["localurle"    ] = URL_data;
	["fullurl"      ] = URL_data;
	["fullurle"     ] = URL_data;
	["canonicalurl" ] = URL_data;
	["canonicalurle"] = URL_data;
	["filepath"     ] = URL_data;
	["urlencode"    ] = URL_data;
	["urldecode"    ] = URL_data;
	["anchorencode" ] = URL_data;
	
	["ns"          ] = namespaces;
	["nse"         ] = namespaces;

	["formatnum"   ] = formatting;
	["#dateformat" ] = formatting;
	["#formatdate" ] = formatting;
	["lc"          ] = formatting;
	["lcfirst"     ] = formatting;
	["uc"          ] = formatting;
	["ucfirst"     ] = formatting;
	["padleft"     ] = formatting;
	["padright"    ] = formatting;

	["plural"      ] = localization;
	["grammar"     ] = localization;
	["gender"      ] = localization;
	["int"         ] = localization;
	
	["#language"   ] = miscellaneous;
	["#special"    ] = miscellaneous;
	["#speciale"   ] = miscellaneous;
	["#tag"        ] = miscellaneous;
	
	-- [[mw:Extension:ParserFunctions]]
	["#expr"       ] = parser_functions_link .. "##expr";
	["#if"         ] = parser_functions_link .. "##if";
	["#ifeq"       ] = parser_functions_link .. "##ifeq";
	["#iferror"    ] = parser_functions_link .. "##iferror";
	["#ifexpr"     ] = parser_functions_link .. "##ifexpr";
	["#ifexist"    ] = parser_functions_link .. "##ifexist";
	["#rel2abs"    ] = parser_functions_link .. "##rel2abs";
	["#switch"     ] = parser_functions_link .. "##switch";
	["#time"       ] = parser_functions_link .. "##time";
	["#timel"      ] = parser_functions_link .. "##timel";
	["#titleparts" ] = parser_functions_link .. "##titleparts";
	
	-- other extensions
	["#invoke"          ] = "mw:Extension:Scribunto";
 	["#babel"           ] = "mw:Extension:Babel";
 	["#categorytree"    ] = "mw:Extension:CategoryTree#The {{#categorytree}} parser function";
 	["#lst"             ] = LST;
 	["#lstx"            ] = LST;
 	["#lsth"            ] = LST; -- not available, it seems
 	["#lqtpagelimit"    ] = "mw:Extension:LiquidThreads";
	["#useliquidthreads"] = "mw:Extension:LiquidThreads";
	["#target"          ] = "mw:Extension:MassMessage"; -- not documented yet
}

-- rudimentary
local function is_valid_pagename(pagename)
	if (pagename == "") or pagename:match("[%[%]%|%{%}#\127<>]") then
		return false
	end
	return true
end

local function hook_special(page)
	if is_valid_pagename(page) then
		return "[[Special:" .. page .. "|" .. page .. "]]"
	else
		return page
	end
end

local parser_function_hooks = {
	["#special" ] = hook_special;
	["#speciale"] = hook_special;
	
	["int"] = function (mesg)
		if is_valid_pagename(mesg) then
			return ("[[:MediaWiki:" .. mesg .. "|" .. mesg .. "]]")
		else
			return mesg
		end
	end;
	
	["#categorytree"] = function (cat)
		if is_valid_pagename(cat) and not (mw.title.getCurrentTitle().fullText == ("Category:" .. cat)) then
			return ("[[:Category:" .. cat .. "|" .. cat .. "]]")
		else
			return cat
		end
	end;
	
	["#invoke"] = function (mod)
		if is_valid_pagename(mod) and not (mw.title.getCurrentTitle().fullText == ("Module:" .. mod)) then
			return ("[[Module:%s|%s]]"):format(mod, mod)
		else
			return mod
		end
	end;
	
	["#tag"] = function (tag)
		local doc_table = require('Module:wikitag link').doc_table
		if doc_table[tag] then
			return ("[[%s|%s]]"):format(doc_table[tag], tag)
		else
			return tag
		end
	end;
}

function export.format_link(frame)
	if mw.isSubsting() then
		return require('Module:unsubst').unsubst_template("format_link")
	end

	local args = (frame.getParent and frame:getParent().args) or frame -- Allows function to be called from other modules.
	local output = { (frame.args and frame.args.nested) and "&#123;&#123;" or "<code>&#123;&#123;" }
	
	local templ = (frame.args and frame.args.annotate) or args[1]
	local noargs = (frame.args and not frame.args.annotate) and next(args) == nil
	
	if not templ then
		if mw.title.getCurrentTitle().fullText == frame:getParent():getTitle() then
			-- demo mode
			return "<code>{{<var>{{{1}}}</var>|<var>{{{2}}}</var>|...}}</code>"
		else
			error("The template name must be given.")
		end
	end

	local function render_title(templ)
		local marker, rest

		marker, rest = templ:match("^([Ss][Uu][Bb][Ss][Tt]):(.*)")
		if not marker then
			marker, rest = templ:match("^([Ss][Aa][Ff][Ee][Ss][Uu][Bb][Ss][Tt]):(.*)")
		end
		if marker then
			templ = rest
			table.insert(output, ("[[mw:Manual:Substitution|%s]]:"):format(marker))
		end
	
		if noargs and variables_nullary[templ] then
			table.insert(output, ("[[%s|%s]]"):format(variables_nullary[templ], templ))
			return
		end
		
		marker, rest = templ:match("^([Mm][Ss][Gg][Nn][Ww]):(.*)")
		if marker then
			templ = rest
			-- not the most accurate documentation ever
			table.insert(output, ("[[m:Help:Magic words#Template modifiers|%s]]:"):format(marker))
		else
			marker, rest = templ:match("^([Mm][Ss][Gg]):(.*)")
			if marker then
				templ = rest	
				table.insert(output, ("[[m:Help:Magic words#Template modifiers|%s]]:"):format(marker)) -- ditto
			end
		end
	
		marker, rest = templ:match("^([Rr][Aa][Ww]):(.*)")
		if marker then
			table.insert(output, ("[[m:Help:Magic words#Template modifiers|%s]]:"):format(marker)) -- missingno.
			templ = rest	
		end
		
		if templ:match("^%s*/") then
			table.insert(output, ("[[%s]]"):format(templ))
			return	
		end
		
		marker, rest = templ:match("^(.-):(.*)")
		if marker then
			local lcmarker = marker:lower()
			if parser_functions[lcmarker] then
				if parser_function_hooks[lcmarker] then
					rest = parser_function_hooks[lcmarker](rest)
				end
				table.insert(output, ("[[%s|%s]]:%s"):format(mw.uri.encode(parser_functions[lcmarker], "WIKI"), marker, rest))
				return
			elseif variables_nonnullary[marker] then
				table.insert(output, ("[[%s|%s]]:%s"):format(variables_nonnullary[marker], marker, rest))
				return
			end
		end
	
		if not is_valid_pagename(templ) then
			table.insert(output, templ)
			return
		end

		if marker then
			if mw.site.namespaces[marker] then
				if (title == "") or (mw.title.getCurrentTitle().fullText == templ) then -- ?? no such variable "title"
					table.insert(output, templ)
				elseif marker == "" and templ:find("^:") then
					-- for cases such as {{temp|:entry}}; MediaWiki displays [[:entry]] without a colon, like [[entry]], but colon should be shown
					table.insert(output, ("[[%s|%s]]"):format(templ, templ))
				else
					table.insert(output, ("[[:%s|%s]]"):format(templ, templ))
				end
				return
			elseif mw.site.interwikiMap()[marker:lower()] then
				-- XXX: not sure what to do now…
				table.insert(output, ("[[:%s:|%s]]:%s"):format(marker, marker, rest))
				return
			end
		end

		if (templ == "") or (mw.title.getCurrentTitle().fullText == ("Template:" .. templ)) then
			table.insert(output, templ)
		else
			table.insert(output, ("[[Template:%s|%s]]"):format(templ, templ))
		end
	end

	render_title(templ)

	local i = (frame.args and frame.args.annotate) and 1 or 2
	while args[i] do
		table.insert(output, "&#124;" .. args[i])
		i = i + 1
	end
	
	for key, value in require("Module:table").sortedPairs(args) do
		if type(key) == "string" then
			table.insert(output, "&#124;" .. key .. "=" .. value)
		end
	end
	
	table.insert(output, (frame.args and frame.args.nested) and "&#125;&#125;" or "&#125;&#125;</code>")
	return table.concat(output)
end

return export