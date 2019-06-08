const express = require('express')

const { createRequestLogger } = require('./requestsLogger')

const staticfilesOptions = { maxAge: 31536000 }

const createServer = (config, logger) => new Promise((resolve, reject) => {
  const app = express()
  app.use(createRequestLogger(config))
  app.use('/workout-records', express.static('static/', staticfilesOptions))

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
