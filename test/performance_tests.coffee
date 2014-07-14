chai = require 'chai'  
should = chai.should()
chaiAsPromised = require("chai-as-promised")
chai.use(chaiAsPromised)

sinon = require 'sinon'

MemoryESM = require('../lib/memory_esm')
PsqlESM = require('../lib/psql_esm')

GER = require('../ger').GER
q = require 'q'

knex = require('knex')({client: 'pg', connection: {host: '127.0.0.1', user : 'root', password : 'abcdEF123456', database : 'ger_test'}})


create_psql_esm = ->
  #in
  psql_esm = new PsqlESM(knex)
  #drop the current tables, reinit the tables, return the esm
  q.fcall(-> psql_esm.drop_tables())
  .then( -> psql_esm.init_tables())
  .then( -> psql_esm)

actions = ["buy", "like", "view"]
people = [1..10000]
things = [1..1000]
create_store_esm = ->
  q.fcall( -> new MemoryESM())

init_ger = ->
  create_psql_esm().then( (esm) -> new GER(esm))

sample = (list) ->
  v = list[Math.floor(Math.random()*list.length)]
  v
describe 'performance tests', ->

  it 'adding 1000 events takes so much time', ->
    console.log ""
    console.log ""
    console.log "####################################################"
    console.log "################# Performance Tests ################"
    console.log "####################################################"
    console.log ""
    console.log ""
    this.timeout(60000);
    init_ger()
    .then((ger) ->
      q.fcall( ->

        st = new Date().getTime()
        
        promises = []
        for x in [1..1000]
          promises.push ger.set_action_weight(sample(actions) , sample([1..10]))
        q.all(promises)
        .then(->
          et = new Date().getTime()
          time = et-st
          pe = time/1000
          console.log "#{pe}ms per set_action_weight"
        )
      )
      .then( ->
        st = new Date().getTime()
        promises = []
        for x in [1..10000]
          promises.push ger.event(sample(people), sample(actions) , sample(things))
        q.all(promises)
        .then(->
          et = new Date().getTime()
          time = et-st
          pe = time/10000
          console.log "#{pe}ms per event"
        )
      )
      .then( ->
        st = new Date().getTime()
        promises = []
        for x in [1..100]
          promises.push ger.recommendations_for_person(sample(people), sample(actions))
        q.all(promises)
        .then(->
          et = new Date().getTime()
          time = et-st
          pe = time/100
          console.log "#{pe}ms per recommendations_for_person"
        )
      )
      .then( ->
        st = new Date().getTime()
        promises = []
        for x in [1..100]
          promises.push ger.recommendations_for_thing(sample(things), sample(actions))
        q.all(promises)
        .then(->
          et = new Date().getTime()
          time = et-st
          pe = time/100
          console.log "#{pe}ms per recommendations_for_thing"
        )
      )
    )
    .then( ->
      console.log ""
      console.log ""
      console.log "####################################################"
      console.log "################# END OF Performance Tests #########"
      console.log "####################################################"
      console.log ""
      console.log ""
    )
