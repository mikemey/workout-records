const supertest = require('supertest')
const fsextra = require('fs-extra')

const backendApp = require('../../app')

const testConfig = {
  port: 9102,
  interface: '127.0.0.1',
  requestslog: 'test.requests.log',
  staticOptions: { maxAge: 86400000 },
  serverPath: '/workout-records-test'
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
  ).then(() => fsextra.remove(testConfig.requestslog))

  const request = () => supertest(app)

  return {
    start,
    stop,
    request,
    config: testConfig
  }
}

module.exports = TestServer
