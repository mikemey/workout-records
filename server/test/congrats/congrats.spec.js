const TestServer = require('../utils/testServer')
const should = require('chai').should()

describe('congratulations message', () => {
  const server = TestServer()
  const requestCongratsMessage = () => server.request().get(`${server.config.serverPath}/api/congrats`)

  const testData = [
    { m: 'message #1' },
    { m: 'message #2' },
    { m: 'message #3' },
    { m: 'message #4' }
  ]

  const clearedTestData = () => testData.map(dbTestMsg => {
    delete dbTestMsg._id
    return dbTestMsg
  })

  before(() => server.start()
    .then(() => server.dropDatabase())
    .then(() => server.insertCongratulations(testData))
  )
  after(() => server.stop())

  it('returns one random message', () => {
    return requestCongratsMessage()
      .expect(200)
      .then(response => {
        should.exist(testData.find(dbTestMsg => dbTestMsg.m === response.body.m))
      })
  })
})
