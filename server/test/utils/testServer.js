const supertest = require('supertest')
const fsextra = require('fs-extra')

const backendApp = require('../../app')
const mongoConn = require('../../app/utils/mongoConnection')

const testConfig = {
  port: 9102,
  interface: '127.0.0.1',
  requestslog: 'test.requests.log',
  staticOptions: { maxAge: 86400000 },
  serverPath: '/workout-records-test',
  mongodb: {
    url: 'mongodb://127.0.0.1:27017',
    dbName: 'workout-test'
  }
}

const quietLogger = {
  info: () => { },
  error: () => { },
  log: () => { }
}

const TestServer = () => {
  let app, server
  process.env.TESTING = 'true'
  const testLogger = quietLogger

  const start = () => backendApp.createServer(testConfig, testLogger)
    .then(wrServer => {
      app = wrServer.app
      server = wrServer.server
    })

  const stop = () => (server
    ? new Promise(resolve => server.close(resolve))
    : Promise.resolve()
  ).then(() => Promise.all([
    fsextra.remove(testConfig.requestslog),
    mongoConn.close()
  ]))

  const request = () => supertest(app)

  const dbhelper = DatabaseHelper()
  return Object.assign({
    start,
    stop,
    request,
    config: testConfig
  }, dbhelper)
}

const DatabaseHelper = () => {
  const dropDatabase = () => mongoConn.dropDatabase()
  const dbCollection = collectionName => mongoConn.collection(collectionName)
  const insertData = (collectionName, data) => dbCollection(collectionName).insertMany(data)
  const getData = (collectionName, find) => dbCollection(collectionName).find(find).toArray()

  const insertCongratulations = data => insertData(mongoConn.congratsCollectionName, data)
  const deleteCongratulations = () => dbCollection(mongoConn.congratsCollectionName).drop()

  const getCongratsRequests = () => getData(mongoConn.congratsReguestCollectionName)
  const insertCongratsRequests = data => insertData(mongoConn.congratsReguestCollectionName, data)
  const deleteCongratsRequests = () => dbCollection(mongoConn.congratsReguestCollectionName).drop()

  return {
    dropDatabase,
    insertCongratulations,
    deleteCongratulations,
    getCongratsRequests,
    insertCongratsRequests,
    deleteCongratsRequests
  }
}

module.exports = TestServer
