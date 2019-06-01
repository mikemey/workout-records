const app = require('./app')
const serverLogger = require('./app/serverLogger')
const configLoader = require('./app/configLoader')

const logger = serverLogger.create()
const config = configLoader.get(logger)

const serverLog = msg => logger.info(`========== ${msg.padEnd(5)} ==========`)

const shutdown = () => {
  serverLog('STOP')
  process.exit(0)
}

process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)

serverLog('START')
app.createServer(config, logger)
  .then(() => serverLog('UP'))
  .catch(err => {
    serverLog('ERROR')
    logger.error(err)
  })
