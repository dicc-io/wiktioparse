#!/usr/bin/env ruby
############################################
# WiktioParse
# for dicc.io
#
# Copyright (c) 2016-2020 
# Yanis Zafirópulos
############################################

## Requirements
##############################

require 'awesome_print'
require 'colorize'
require 'csv'
require 'json'
require 'open-uri'
require 'twitter_cldr'

## Constants
##############################

$WiktionaryUrl          = "https://en.wiktionary.org/w/api.php?action=query&prop=revisions&rvprop=content&format=json&formatversion=2&titles="

$PartsOfSpeech          = ["Adjective", "Adverb", "Noun", "Verb"]
$CollapsableSections    = ["Alternative forms", "Anagrams", "Antonyms", "Conjugation", "Declension", "Derived terms", "Descendants", "Etymology", "Pronunciation", "Related terms", "Romanization", "See also", "Synonyms", "Translations"]
$IgnoredSections        = ["Further reading", "Usage notes"]

## Helpers
##############################

class String
    def containsOneOf(arr)
        arr.each{|item|
            if self.include? item
                return true
            end
        }
        return false
    end
end

## Main
##############################

class WiktioParse

    def initialize(word)
        @word = word
    end

    def treeify(parsed)
        # find what the top level is first
        topLevel = -1
        parsed.each{|line|
            if (m=line.match(/(={2,})([^=]+)(\1)/))
                topLevel = m.captures[0].length
                break
            end
        }

        # second pass
        result = {}
        path = []
        current = result
        currentLevel = 0
        parsed.each{|line|
            if (m=line.match(/(={2,})([^=]+)(\1)/))
                # if the line is a header, 
                # start a new section

                level = m.captures[0].length
                header = m.captures[1].strip

                if level <= currentLevel
                    while path.count>level-topLevel
                        path.pop()
                    end
                end

                path.push(header)
                
                current = result
                path.each{|p|
                    if not current.key? (p)
                        current[p] = {}
                    end
                    current = current[p]
                }

                current["_"] = []

                currentLevel = level
                puts "found level #{level} -> #{header}"
            else
                # add line to current section

                if not current["_"].nil?
                    current["_"] << line
                end
            end
        }

        return result
    end

    def cleanupTree(tree, level=0)
        def stripEmptyLines(arr)
            arr.map{|x| x.strip}.select{|x| x!="" and not x=~/^[\-]+$/}
        end

        if level==1 and tree.key? "_"
            tree.delete("_")
        end
        tree.keys.each{|k|
            if k.containsOneOf $PartsOfSpeech
                tree[k]["Definitions"] = stripEmptyLines(tree[k]["_"])
                tree[k].delete("_")
            end

            if k.containsOneOf $IgnoredSections
                tree.delete(k)
            end

            if k.containsOneOf $CollapsableSections
                tree[k] = stripEmptyLines(tree[k]["_"])
            else
                if tree[k].is_a? Hash
                    cleanupTree(tree[k], level+1)
                end
            end
        }
    end

    def fetch()
        url = $WiktionaryUrl + @word

        data = open(URI.escape(url)).read
        parsed = JSON.parse(data)
     
        begin 
            return parsed["query"]["pages"][0]["revisions"][0]["content"].split("\n")
        rescue
            return nil
        end
    end

    def process()
        fetched = fetch()
        return nil if fetched.nil?

        data = cleanupTree(treeify(fetched))
        return data
    end
end

## Terminal utility
##############################

if __FILE__ == $0
    word = ARGV[0]

    wp = WiktioParse.new(word)
    ap wp.process()
end