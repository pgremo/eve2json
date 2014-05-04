chai = require 'chai'
parser = require '../index'

chai.should()

describe 'Parse Asset', ->
  data = """
Coolant	5,655	Refined Commodities			8,482.50 m3
Enriched Uranium	5,600	Refined Commodities			8,400 m3
Robotics	1,533	Specialized Commodities			9,198 m3
Tritanium	5	Mineral			0.05 m3
"""
  it 'Simple List', ->
    parser
      .parse data
      .should
      .be
      .eql [[{
          name: 'Coolant'
          quantity: 5655
          category: ''
          group: 'Refined Commodities'
          volume: 8482.5
          size: ''
          slot: undefined
          metaLevel: undefined
          techLevel: undefined
        },{
          name: 'Enriched Uranium'
          quantity: 5600
          category: ''
          group: 'Refined Commodities'
          volume: 8400
          size: ''
          slot: undefined
          metaLevel: undefined
          techLevel: undefined
        },{
          name: 'Robotics'
          quantity: 1533
          category: ''
          group: 'Specialized Commodities'
          volume: 9198
          size: ''
          slot: undefined
          metaLevel: undefined
          techLevel: undefined
        },{
          name: 'Tritanium'
          quantity: 5
          category: ''
          group: 'Mineral'
          volume: .05
          size: ''
          slot: undefined
          metaLevel: undefined
          techLevel: undefined
        }], []]