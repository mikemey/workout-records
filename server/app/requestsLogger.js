const fs = require('fs')
const morgan = require('morgan')

const dateFormat = require('./logDateFormat')

const createRequestLogger = config => {
  morgan.token('dateTime', dateFormat)
  morgan.token('clientIP', req => req.headers['x-forwarded-for'] || req.connection.remoteAddress)
  const format = '[:dateTime] [:clientIP] :method :url [:status] [:res[content-length] bytes] - :response-time[0]ms :user-agent'

  const options = {}
  options.skip = () => process.env.TESTING !== undefined
  if (config.requestslog) {
    options.stream = fs.createWriteStream(config.requestslog, { flags: 'a' })
  }

  return morgan(format, options)
}

module.exports = { createRequestLogger }
