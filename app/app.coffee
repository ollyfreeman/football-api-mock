express = require('express')
TokenProvider = require('./token-provider')

app = express()
tokenProvider = new TokenProvider

require('./config')(app)
require('./routes')(app, '/api/', tokenProvider)

module.exports = app

app.listen app.settings.port, () ->
    console.log "Listening at http://localhost:#{app.settings.port}"