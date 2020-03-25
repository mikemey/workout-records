const express = require('express')
const moment = require('moment')
const mongoConn = require('../utils/mongoConnection')

const createCongratulationsRouter = logger => {
  const router = express.Router()
  const congratsRepo = CongratulationsRepo()

  router.get('/', (req, res) => congratsRepo.getRandomMessage()
    .then(message => {
      if (!message) return res.status(501).send()
      const msgRequest = {
        m: message.m,
        ip: req.headers['x-forwarded-for'] || req.connection.remoteAddress,
        v: req.query.v || '',
        date: moment.utc().toDate()
      }
      return congratsRepo.storeMessageRequest(msgRequest)
        .then(() => res.status(200).send(message))
    })
    .catch(error => {
      logger.error('error getting congratulations message', error)
      res.status(500).send('server error')
    })
  )

  return router
}

const CongratulationsRepo = () => {
  const congratsCollection = mongoConn.collection(mongoConn.congratsCollectionName)
  const congratsRequestCollection = mongoConn.collection(mongoConn.congratsReguestCollectionName)

  const getRandomMessage = () => congratsCollection
    .aggregate([
      { $sample: { size: 1 } },
      { $project: { _id: 0, m: 1 } }
    ])
    .toArray()
    .then(docs => docs[0])

  const storeMessageRequest = messageRequest => congratsRequestCollection.insertOne(messageRequest)

  return {
    getRandomMessage,
    storeMessageRequest
  }
}

module.exports = { createCongratulationsRouter }
