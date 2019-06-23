const fs = require('fs')
const morgan = require('morgan')

const dateFormat = require('./logDateFormat')

const suppressRequestLog = [
  '/api/metadata',
  '/api/version'
]

const createRequestLogger = config => {
  morgan.token('dateTime', dateFormat)
  morgan.token('clientIP', req => req.headers['x-forwarded-for'] || req.connection.remoteAddress)
  const format = '[:dateTime] [:clientIP] :method :url [:status] [:res[content-length] bytes] - :response-time[0]ms :user-agent'

  const options = {}
  options.skip = (req, res) =>
    process.env.TESTING !== undefined ||
    suppressRequestLog.some(excludePath => req.originalUrl.match(excludePath)) ||
    res.statusCode === 304
  if (config.requestslog) {
    options.stream = fs.createWriteStream(config.requestslog, { flags: 'a' })
  }

  return morgan(format, options)
}

module.exports = { createRequestLogger }
