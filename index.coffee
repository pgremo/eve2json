numeral = require 'numeral'
l = require 'lodash'

splitAndStrip = (s) ->
  lines = for line in s.trim().replace(/\r\n|\n\r|\n|\r/g,'\n').split(/\n/)
    line.trim().replace('\xa0', '').replace('\xc2', '')
  line for line in lines when line?

matchLines = (regex, lines) ->
  matches = []
  badLines = []
  for line in lines
    regex.lastIndex = 0
    match = line.match regex
    if match?
      matches.push match[1..]
    else
      badLines.push line
  [matches, badLines]

ASSET_LIST = ///
   ^([\S\x20]*)                         # name
  \t([\d,\.]*)                          # quantity
  (\t([\S\x20]*))?                      # group
  (\t([\S\x20]*))?                      # category
  (\t(XLarge|Large|Medium|Small|))?     # size
  (\t(High|Medium|Low|Rigs|[\d\x20]*))? # slot
  (\t([\d\x20,\.]*)\x20m3)?             # volume
  (\t([\d]+|))?                         # meta level
  (\t([\d]+|))?$                        # tech level
///

module.exports.hanger = (lines) ->
  [matches, badLines] = matchLines ASSET_LIST, lines
  result = for [name, quantity, _, group, _, category, _, size, _, slot, _, volume, _, meta_level, _, tech_level] in matches
    {
      name: name
      quantity: numeral().unformat(quantity) or 1
      group: group
      category: category
      size: size
      slot: slot
      volume: numeral().unformat(volume) or 0
      metaLevel: meta_level
      techLevel: tech_level
    }
  [result, badLines]

# 10 x Cargo Scanner II | 10x Cargo Scanner II | 10 Cargo Scanner II
LISTING_RE = /^([\d,\.]+?)\x20?x?\x20([\S\x20]+)$/
# Cargo Scanner II x10 | Cargo Scanner II x 10 | Cargo Scanner II 10
LISTING_RE2 = /^([\S\x20]+?)\x20x?\x20?([\d,\.]+)$/
# Cargo Scanner II
LISTING_RE3 = /^([\S\x20]+)$/

module.exports.list = (lines) ->
  result = []

  [matches, badLines] = matchLines LISTING_RE, lines
  for [quantity, name] in matches
    result.push name: name.trim(), quantity: numeral().unformat(quantity) or 1

  [matches, badLines] = matchLines LISTING_RE2, badLines
  for [name, quantity] in matches
    result.push name: name.trim(), quantity: numeral().unformat(quantity) or 1

  [matches, badLines] = matchLines LISTING_RE3, badLines
  for [name] in matches
    result.push name: name.trim(), quantity: 1

  [result, badLines]

module.exports.parse = (raw, parsers = [module.exports.hanger, module.exports.list]) ->
  lines = splitAndStrip raw
  result = while (parser = parsers.shift()) and lines
    [good, lines] = parser lines; good
  [l.flatten(result), lines]
