###express = require('express')
dataProvider = require('./data-provider')
fileLoader = require('./file-loader')

app = express()

require('./config')(app)
require('./routes')('/api/', app)

module.exports = app

app.listen app.settings.port, () ->
    console.log "Example app listening at http://localhost:#{app.settings.port}"###

TokenStore = require('../app/token-store')
MULTIPLIER = 12600

tokenStore = new TokenStore
actualTokenId = tokenStore.getNewToken(2 * MULTIPLIER, Date.now())