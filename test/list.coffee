chai = require 'chai'
parser = require '../index'

chai.should()

describe 'Parse Listing', ->
  data = """
Clear Icicle x10
Krystallos 13
3 Scordite
65 Mercoxit
Iridescent Gneiss
Massive Scordite
"""
  it 'Simple List', ->
    parser
      .parse data
      .should
      .be
      .eql [[{
          name: 'Scordite'
          quantity: 3
        }, {
          name: 'Mercoxit'
          quantity: 65
        },{
          name: 'Clear Icicle'
          quantity: 10
        }, {
          name: 'Krystallos'
          quantity: 13
        },  {
          name: 'Iridescent Gneiss'
          quantity: 1
        }, {
          name: 'Massive Scordite'
          quantity: 1
        }], []]