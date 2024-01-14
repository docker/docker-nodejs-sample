if (process.env.POSTGRES_HOST) module.exports = require('./postgres');
else module.exports = require('./sqlite');
