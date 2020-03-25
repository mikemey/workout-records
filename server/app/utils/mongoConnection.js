const { MongoClient } = require('mongodb')

const congratsCollectionName = 'cgmsgs'
const congratsReguestCollectionName = 'cgreqs'

const PRODUCTION_ENV = 'PROD'

class MongoConnectionError extends Error {
  constructor (message) {
    super(message)
    this.name = this.constructor.name
    Error.captureStackTrace(this, this.constructor)
  }
}

const defaultIndexOptions = { background: true, unique: true }

const ALL_INDEX_SPECS = [{
  collection: congratsReguestCollectionName,
  fields: { ip: 1 },
  options: { name: 'ix_ip', unique: false }
}]

const connection = {
  mongoClient: null,
  mongoDB: null
}

const connect = (config, logger) => {
  if (connection.mongoDB) return Promise.resolve()

  const url = config.mongodb.url
  const dbName = config.mongodb.dbName
  logger.info('connection to DB...')
  return initializeDirectConnection(url, dbName)
    .then(() => {
      logger.info('DB connections established.')
    })
    .catch(error => {
      logger.error(`No connection to DB: ${url}`, error)
      return close().then(() => { throw error })
    })
}

const initializeDirectConnection = (url, dbName) => {
  return checkProductionEnvironment(dbName)
    .then(() => MongoClient.connect(url, { useNewUrlParser: true, useUnifiedTopology: true }))
    .then(client => {
      connection.mongoClient = client
      return client.db(dbName)
    })
    .then(db => { connection.mongoDB = db })
    .then(ensureAllIndices)
}

const checkProductionEnvironment = dbName => new Promise((resolve, reject) => {
  if (dbName === 'workout-records') {
    if (process.env.NODE_ENV !== PRODUCTION_ENV) {
      const msg = `Access to production database with invalid NODE_ENV: ${process.env.NODE_ENV}`
      reject(new MongoConnectionError(msg))
    }
  }
  resolve()
})

const ensureAllIndices = () =>
  Promise.all(ALL_INDEX_SPECS.map(indexSpec => {
    const fullOptions = Object.assign({}, defaultIndexOptions, indexSpec.options)
    return connection.mongoDB
      .collection(indexSpec.collection)
      .createIndex(indexSpec.fields, fullOptions)
  }))

const close = () => (connection.mongoClient
  ? connection.mongoClient.close()
  : Promise.resolve()
).then(cleanupInstances)

const cleanupInstances = () => {
  connection.mongoClient = null
  connection.mongoDB = null
}

const collection = name => connection.mongoDB.collection(name)

const dropDatabase = () => {
  if (!process.env.TESTING) {
    const msg = 'Dropping database only with process.env.TESTING set'
    throw new MongoConnectionError(msg)
  }
  return connection.mongoDB.dropDatabase().then(ensureAllIndices)
}

module.exports = {
  connect,
  close,
  dropDatabase,
  collection,
  congratsCollectionName,
  congratsReguestCollectionName
}
