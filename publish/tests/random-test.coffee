#mocha --compilers coffee:coffee-script * -R spec
 
chai = require 'chai'
chai.should()

describe 'random task', ->
  task1 = {}
  it 'should have a name', ->
    task1.name = 'name'
    task1.name.should.equal 'name'
  
  it 'should be initially incomplete', ->
    task1.status = 'incomplete'
    task1.status.should.equal 'incomplete'
