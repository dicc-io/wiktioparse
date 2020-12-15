-- Simplified implementation of mw for running WikiMedia Scribunto code
-- under Python
--
-- Copyright (c) 2020 Tatu Ylonen.  See file LICENSE and https://ylonen.org

mw = {
   -- addWarning  (see below)
   -- allToString  (see below)
   -- clone  (see below)
   -- dumpObject  (see below)
   -- getCurrentFrame -- assigned in lua_invoke for each call
   hash = require("mwhash"),
   html = require("mwhtml"),
   -- incrementExpensiveFunctionCount (see below)
   -- isSubsting  (see below)
   language = require("mwlanguage"),
   -- loadData  (see below)
   -- log  (see below)
   -- logObject  (see below)
   -- XXX message.*
   site = require("mwsite"),
   text = require("mwtext"),
   title = require("mwtitle"),
   uri = require("mwuri"),
   ustring = require("ustring.ustring")
}

-- This can also be accessed with just the mw prefix
mw.getContentLanguage = mw.language.getContentLanguage

function mw.addWarning(text)
   print("mw.addWarning", text)
end

function mw.allToString(...)
   local ret = ""
   for k, v in pairs(...) do
      ret = ret .. tostring(v)
   end
   return ret
end

local function deepcopy(obj, visited)
   -- non-table objects can be returned as-is
   if type(obj) ~= "table" then return obj end
   -- handle cyclic data structures
   if visited[obj] ~= nil then return visited[obj] end
   -- Create new table
   local new_table = {}
   -- track that we have visited this node and save the copy
   visited[obj] = new_table
   -- clear metatable during the copy, as it could interfere
   local old_meta = getmetatable(obj)
   setmetatable(obj, nil)
   -- Copy fields of the object
   for k, v in pairs(obj) do
      new_table[deepcopy(k, visited)] = deepcopy(v, visited)
   end
   -- copy metatable pointer for copy
   setmetatable(obj, old_meta)
   setmetatable(new_table, old_meta)
   return new_table
end

function mw.clone(v)
   local ret = deepcopy(v, {})
   -- print("mw_clone: " .. tostring(ret))
   return ret
end

function mw.dumpObject(obj)
   print("mw.dumpObject", obj)
end

function mw.incrementExpensiveFunctionCount()
   print("mw.incrementExpensiveFunctionCount")
end

function mw.isSubsting()
   return false
end

-- mw.loadData function - loads a data file.  This is same as require(),
-- which already implements caching.
function mw.loadData(modname)
   return require(modname)
end

function mw.log(...)
   -- print("mw.log", ...)
end

function mw.logObject(obj)
   -- print("mw.logObject", obj)
end

function mw.getCurrentFrame()
   return mw._frame
end

-- mw.getLanguage is an alias for mw.language.new
mw.getLanguage = mw.language.new

return mw
