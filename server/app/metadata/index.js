const express = require('express')
const moment = require('moment')
const fsextra = require('fs-extra')

const mongoConn = require('../utils/mongoConnection')
const pjson = require('../../package.json')

const createMetadataRouter = (config, logger) => {
  const router = express.Router()
  const now = moment.utc().toISOString()
  const version = `v${pjson.version} (${now})`
  logger.info(`server version: ${version}`)

  router.get('/version', (_, res) => res.status(200).send(version))

  router.get('/metadata', (_, res) => {
    const metadata = {
      requestLogSize: 0,
      congratsMessages: 0
    }
    return Promise.all([
      fsextra.stat(config.requestslog),
      mongoConn.collection(mongoConn.congratsReguestCollectionName).countDocuments()
    ]).then(([stat, congratsRequests]) => {
      metadata.requestLogSize = stat.size
      metadata.congratsMessages = congratsRequests
    }).catch(err => { logger.error(`get request log file error: ${err.message}`) })
      .finally(() => res.status(200).send(metadata))
  })

  return router
}

module.exports = { createMetadataRouter }
