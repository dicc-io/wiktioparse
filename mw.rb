#!/usr/bin/env ruby
require 'rufus-lua'

module MW

    class IPA
        def initialize
            @Lua = Rufus::Lua::State.new
            @Lua.eval("require('mw')")

            @modules = Dir["mediawiki/modules/*_ipa.lua"].map{|x| File.basename(x).gsub("_ipa.lua","") }.select{|x| not x.start_with? "_"}
            @modules.each{|modu|
                @Lua.eval("#{modu} = require('#{modu}_ipa')")
            }
        end

        def get(lang,word)
            return nil if not @modules.include? lang
            return @Lua.eval("return #{lang}.convertToIPA('#{word}')").force_encoding("UTF-8")
        end

        def supports?(lang)
            return @modules.include?(lang)
        end
    end
end

## Terminal utility
##############################

if __FILE__ == $0
    $ipa = MW::IPA.new

    ["uno", "dos", "canción", "dedo", "cadena"].each{|word|
        puts word + " => " + $ipa.get("es", word)
    }
end