numeral = require 'numeral'
l = require 'lodash'

splitAndStrip = (s) ->
  lines = for line in s.replace(/\r\n|\n\r|\n|\r/g,'\n').split(/\n/)
    line.replace('\xa0', '').replace('\xc2', '')
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

hanger = module.exports.hanger = (lines) ->
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
LISTING1 = /^([\d,\.]+?)\x20?x?\x20([\S\x20]+)$/
# Cargo Scanner II x10 | Cargo Scanner II x 10 | Cargo Scanner II 10
LISTING2 = /^([\S\x20]+?)\x20x?\x20?([\d,\.]+)$/
# Cargo Scanner II
LISTING3 = /^([\S\x20]+)$/

list = module.exports.list = (lines) ->
  result = []

  [matches, lines] = matchLines LISTING1, lines
  result.push (for [quantity, name] in matches
    name: name.trim(), quantity: numeral().unformat(quantity) or 1)...

  [matches, lines] = matchLines LISTING2, lines
  result.push (for [name, quantity] in matches
    name: name.trim(), quantity: numeral().unformat(quantity) or 1)...

  [matches, lines] = matchLines LISTING3, lines
  result.push (for [name] in matches
    name: name.trim(), quantity: 1)...

  [result, lines]


PI1 = ///
  ^([\d,\.]+)\t             # quantity
  ([\S\x20]+)\t             # name
  (Routed|Not\x20routed)$   # routed
///
PI2 = ///
  ^\t           # icon
  ([\S\x20]+)\t # name
  ([\d,\.]+)\t  # quantity
  ([\d,\.]+)$   # volume
///
PI3 = ///
  ^\t           # icon
  ([\S\x20]+)\t # name
  ([\d,\.]+)$   # quantity
///

pi = module.exports.pi = (lines) ->
  result = []

  [matches, lines] = matchLines PI1, lines
  result.push (for [quantity, name, routed] in matches
    name: name.trim(), quantity: numeral().unformat(quantity) or 1, routed: routed is 'Routed')...

  [matches, lines] = matchLines PI2, lines
  result.push (for [name, quantity, volume] in matches
    name: name.trim(), quantity: numeral().unformat(quantity) or 1, volume: numeral().unformat(volume) or 1)...

  [matches, lines] = matchLines PI3, lines
  result.push (for [name, quantity] in matches
    name: name.trim(), quantity: numeral().unformat(quantity) or 1)...

  return [result, lines]

module.exports.parse = (raw, parsers = [pi, hanger, list]) ->
  lines = splitAndStrip raw
  result = while (parser = parsers.shift()) and lines
    [good, lines] = parser lines; good
  [l.flatten(result), lines]
