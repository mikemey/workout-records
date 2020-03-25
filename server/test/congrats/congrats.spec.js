const TestServer = require('../utils/testServer')
const should = require('chai').should()

describe('congratulations message endpoint', () => {
  const server = TestServer()
  const testIp = '123.123.123.123'
  const requestCongratsMessage = versionParam => {
    const versionQuery = versionParam ? `?v=${versionParam}` : ''
    return server.request()
      .get(`${server.config.serverPath}/api/congrats${versionQuery}`)
      .set('X-FORWARDED-FOR', testIp)
  }

  const testData = [
    { m: 'message #1' },
    { m: 'message #2' },
    { m: 'message #3' },
    { m: 'message #4' }
  ]

  before(() => server.start())
  beforeEach(() => server.dropDatabase()
    .then(() => server.insertCongratulations(testData))
  )

  after(() => server.stop())

  describe('responds', () => {
    it('with one random message', () => requestCongratsMessage()
      .expect(200)
      .then(response => {
        should.exist(testData.find(dbTestMsg => dbTestMsg.m === response.body.m))
      })
    )

    it('with 501 when no data', () => server.deleteCongratulations()
      .then(() => requestCongratsMessage().expect(501))
    )

    it('and stores message returned', () => {
      let congratsMessage = ''
      const clientVersion = '1.2.2'
      return requestCongratsMessage(clientVersion).expect(200)
        .then(response => {
          congratsMessage = response.body.m
          return server.getCongratsRequests()
        })
        .then(requests => {
          requests.should.have.length(1)
          requests[0].m.should.equal(congratsMessage)
          requests[0].ip.should.equal(testIp)
          requests[0].v.should.equal(clientVersion)
          should.exist(requests[0].date)
        })
    })

    it('and stores message without client-version', () =>
      requestCongratsMessage().expect(200)
        .then(() => server.getCongratsRequests())
        .then(requests => {
          requests.should.have.length(1)
          requests[0].v.should.equal('')
        }))
  })
})
