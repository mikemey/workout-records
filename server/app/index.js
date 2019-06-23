const express = require('express')

const { createRequestLogger } = require('./requestsLogger')
const { createMetadataRouter } = require('./metadata')

const createServer = (config, logger) => new Promise((resolve, reject) => {
  const app = express()
  app.use(createRequestLogger(config))
  app.use(`${config.serverPath}`, express.static('static/', config.staticOptions))
  app.use(`${config.serverPath}/api`, createMetadataRouter(config, logger))

  const server = app.listen(config.port, config.interface, () => {
    logger.info(`Started on port ${server.address().port}`)
    return resolve({ app, server })
  })

  server.once('error', err => {
    logger.error(`server error: ${err.message}`)
    logger.log(err)
    return reject(err)
  })
})

module.exports = { createServer }
