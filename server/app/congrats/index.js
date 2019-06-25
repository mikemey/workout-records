const express = require('express')
const moment = require('moment')
const mongoConn = require('../utils/mongoConnection')

const createCongratulationsRouter = (config, logger) => {
  const router = express.Router()
  const congratsRepo = CongratulationsRepo()

  router.get('/', (_, res) => congratsRepo.getRandomMessage()
    .then(message => res.status(200).send(message))
  )

  return router
}

const CongratulationsRepo = () => {
  const congratsCollection = mongoConn.collection(mongoConn.congratsCollectionName)

  const getRandomMessage = () => congratsCollection
    .aggregate([
      { $sample: { size: 1 } },
      { $project: { _id: 0, m: 1 } }
    ])
    .toArray()
    .then(docs => docs[0])

  return {
    getRandomMessage
  }
}

module.exports = { createCongratulationsRouter }
