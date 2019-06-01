const moment = require('moment')

module.exports = () => moment().utc().format('YYYY-MM-DD HH:mm:ss z')
