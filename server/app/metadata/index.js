const express = require('express')
const moment = require('moment')
const fsextra = require('fs-extra')

const pjson = require('../../package.json')

const createMetadataRouter = (config, logger) => {
  const router = express.Router()
  const now = moment.utc().toISOString()
  const version = `v${pjson.version} (${now})`
  logger.info(`server version: ${version}`)

  router.get('/version', (_, res) => res.status(200).send(version))

  router.get('/metadata', (_, res) => {
    const metadata = {
      requestLogSize: 0
    }
    return fsextra.stat(config.requestslog)
      .then(stat => { metadata.requestLogSize = stat.size })
      .catch(err => { logger.error(`get request log file error: ${err.message}`) })
      .finally(() => res.status(200).send(metadata))
  })

  return router
}

module.exports = { createMetadataRouter }
