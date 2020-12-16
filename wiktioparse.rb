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

require './mw'

## Globals
##############################

$IPA = MW::IPA.new

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

    def cleanupWikitext()
        self.gsub("[","")
            .gsub("]","")
            .strip
    end

    def cleanIPA()
        self.gsub(/^\/+|\/+$/, '')
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
                puts ("\t" * (level-1)) + header
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

    def processSubTree(tree, labels, action, preaction=nil, language=nil, level=0)
        return unless tree.is_a? Hash

        tree.each{|k,v|
            if level==0
                language = k
            end

            if labels.include? k
                if preaction.nil?
                    tree[k] = method(action).call(v)
                else
                    method(preaction).call(language, level, tree, k, v)
                end
            else
                if k=="Forms"
                    v.each{|form|
                        processSubTree(form, labels, action, preaction, language, level+1)
                    }
                else
                    processSubTree(v, labels, action, preaction, language, level+1)
                end
            end
        }
    end

    def convertPronunciation(lst)
        result = []
        lst.each{|line|
            pron = {}
            if (m=line.match(/\{\{.+IPA\|(?:[a-z]+\|)?([^\}]+)\}\}/))
                ipa = m.captures[0]
                pron["ipa"] = ipa.cleanIPA()
            end
            if (m=line.match(/\{\{a\|([^\}]+)\}\}/))
                tag = m.captures[0]
                pron["tag"] = tag
            end

            if pron.keys.count > 0 and pron.key? "ipa"
                result << pron
            end
        }
        return result
    end

    def convertOnyms(lst)
        result = {}
        lst.each{|line|
            if (m=line.match(/\{\{sense\|([^\}]+)\}\}/))
                sense = m.captures[0]
                result[sense] = []

                if (matches=line.scan(/\{\{l\|[a-z]+\|([^\}\|]+)(?:\||\})/))
                    matches.each{|m|
                        result[sense] << m[0].strip
                    }
                end
            end
        }
        return result
    end

    def convertTerms(lst)
        result = []
        lst.each{|line|
            if (m=line.match(/.*\|([^\}]+)$/))
                if m.captures[0]!="en"
                    result << m.captures[0].strip
                end
            end
        }
        return result
    end

    def prepareTranslations(language, level, tree, k, v)
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
            processSubTree(tree[k], ["Translations"], :convertTranslations, :prepareTranslations, language, level+1)
        else
            tree[k] = convertTranslations(v)
        end
    end

    def convertTranslations(lst)
        dict = {}
        sense = ""

        lst.each{|line|
            if (m=line.match(/\{\{trans-top\|([^\}]+)\}\}/))
                sense = m.captures[0].strip
                dict[sense] = {}
            else
                matches = line.scan(/\{\{t\+?\|([a-z]+)\|([^\}\|]+)(?:\||\})/)
                matches.each{|m|
                    lang = m[0].strip
                    word = m[1].strip

                    dict[sense][lang] = [] if not dict[sense].key? lang

                    cleanWord = word.cleanupWikitext()
                    
                    if $IPA.supports? lang 
                        dict[sense][lang] << {
                            word: cleanWord,
                            ipa: $IPA.get(lang, cleanWord)
                        }
                    else
                        dict[sense][lang] << cleanWord
                    end
                }
                if matches.count > 0
                    ap matches
                end
            end
        }
        return dict
    end

    def process()
        fetched = fetch()
        return nil if fetched.nil?

        data = cleanupTree(treeify(fetched))

        # Translations
        processSubTree(data, ["Pronunciation"],                  :convertPronunciation)
        processSubTree(data, ["Antonyms", "Synonyms"],           :convertOnyms)
        processSubTree(data, ["Derived terms", "Related terms"], :convertTerms)
        processSubTree(data, ["Translations"],                   :convertTranslations, :prepareTranslations)

        return data
    end
end

## Terminal utility
##############################

if __FILE__ == $0
    word = ARGV[0]

    wp = WiktioParse.new(word)
    final = wp.process()

    File.open("test.json","w"){|f|
        f.write(JSON.pretty_generate(final))
    }
end