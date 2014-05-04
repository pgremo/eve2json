chai = require 'chai'
parser = require '../index'

chai.should()

describe 'Parse PI', ->
  data = """
331.0\tAqueous Liquids\tNot routed
331\tElectrolytes\tRouted
\tToxic Metals\t305.0\t3.05
\tRobotics\t205.0
"""
  it 'Simple List', ->
    parser
    .parse data
    .should
    .be
    .eql [[{
      name: 'Aqueous Liquids'
      quantity: 331
      routed: false
    }, {
      name: 'Electrolytes'
      quantity: 331
      routed: true
    },{
      name: 'Toxic Metals'
      quantity: 305
      volume: 3.05
    }, {
      name: 'Robotics'
      quantity: 205
    }], []]