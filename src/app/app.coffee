express = require('express')
dataProvider = require('./data-provider')
fileLoader = require('./file-loader')
TokenProvider = require('./token-provider')

app = express()
tokenProvider = new TokenProvider

require('./config')(app)
require('./routes')(app, '/api/', tokenProvider)

module.exports = app

app.listen app.settings.port, () ->
    console.log "Example app listening at http://localhost:#{app.settings.port}"