const express = require('express')

const mongoConn = require('./utils/mongoConnection')
const { createRequestLogger } = require('./requestsLogger')
const { createMetadataRouter } = require('./metadata')
const { createCongratulationsRouter } = require('./congrats')

const createServer = (config, logger) => mongoConn.connect(config, logger)
  .then(() => new Promise((resolve, reject) => {
    const app = express()
    app.use(createRequestLogger(config))
    app.use(`${config.serverPath}`, express.static('static/', config.staticOptions))
    app.use(`${config.serverPath}/api`, createMetadataRouter(config, logger))
    app.use(`${config.serverPath}/api/congrats`, createCongratulationsRouter(config, logger))

    const server = app.listen(config.port, config.interface, () => {
      logger.info(`Started on port ${server.address().port}`)
      return resolve({ app, server })
    })

    server.once('error', err => {
      logger.error(`server error: ${err.message}`)
      logger.log(err)
      return reject(err)
    })
  }))

module.exports = { createServer }
