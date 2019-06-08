const DEFAULT_ENV = 'default'
const PROD_ENV = 'PROD'

const defaultEnv = {
  port: 9100,
  interface: '0.0.0.0'
}

const prodEnv = {
  port: 8002,
  interface: '127.0.0.1',
  requestslog: 'wr.requests.log'
}

const message = environment => `using ${environment} environment configuration`

const get = logger => {
  switch (process.env.NODE_ENV) {
    case PROD_ENV:
      logger.info(message(PROD_ENV))
      return Object.assign({}, defaultEnv, prodEnv)
    default:
      logger.info(message(DEFAULT_ENV))
      return defaultEnv
  }
}

module.exports = { get }
