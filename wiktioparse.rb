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

$WiktionaryUrl              = "https://en.wiktionary.org/w/api.php?action=query&prop=revisions&rvprop=content&format=json&formatversion=2&titles="

$PartsOfSpeech              = ["Adjective", "Adverb", "Noun", "Verb"]
$CollapsableSections        = ["Alternative forms", "Anagrams", "Antonyms", "Conjugation", "Declension", "Derived terms", "Descendants", "Pronunciation", "Related terms", "Romanization", "See also", "Synonyms", "Translations"]
$SemiCollapsableSections    = ["Etymology"]
$IgnoredSections            = ["Further reading", "References", "Usage notes"]

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

            if k.containsOneOf $SemiCollapsableSections
                cleanedDash = stripEmptyLines(tree[k]["_"])
                if tree[k].keys.count == 1
                    tree[k] = cleanedDash
                else
                    tree[k]["_"] = cleanedDash
                end
            end 

            if k.containsOneOf $CollapsableSections
                tree[k] = stripEmptyLines(tree[k]["_"])
            else
                if tree[k].is_a? Hash
                    cleanupTree(tree[k], level+1)
                end
            end

            if k =~ /Etymology \d/
                tree["Forms"]=[] if not tree.key? "Forms"
                processed = tree[k]
                if processed.key? "_"
                    processed["Etymology"] = processed["_"]
                    processed.delete("_")
                end

                tree["Forms"] << processed
                tree.delete(k)
            end
        }

        tree.each{|k,v|
            if v.is_a? Hash and not v.key? "Forms"
                subforms = []
                $PartsOfSpeech.each{|pos|
                    if v.key? pos 
                        subforms << {
                            pos => v[pos]
                        }
                        tree[k].delete(pos)
                    end
                }
                if subforms!=[]
                    tree[k]["Forms"] = subforms
                end
            end
        }

        return tree
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

    def doTranslations(tree, language=nil, level=0)
        return unless tree.is_a? Hash

        tree.each{|k,v|
            if level==0
                language = k
            end

            if k=="Translations"
                if (m=v[0].match (/see translation subpage\|([^\}]+)/))
                    pos = m.captures[0]
                    subwp = WiktioParse.new(@word + "/translations")
                    subtrans = subwp.process()[language]

                    if subtrans.key? "Forms"
                        subtrans["Forms"].each{|form|
                            if form.key? pos
                                subtrans = form[pos]["Translations"]
                                break
                            end
                        }
                    else
                        subtrans = subtrans[pos]["Translations"]
                    end

                    tree[k] = subtrans
                end
            else
                if k=="Forms"
                    v.each{|form|
                        doTranslations(form, language, level+1)
                    }
                else
                    doTranslations(v, language, level+1)
                end
            end
        }
    end

    def process()
        fetched = fetch()
        return nil if fetched.nil?

        data = cleanupTree(treeify(fetched))

        doTranslations(data)

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