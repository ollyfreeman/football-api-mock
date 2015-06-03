express = require('express')
dataProvider = require('./data-provider')
fileLoader = require('./file-loader')

app = express()

require('./config')(app)
require('./routes')('/api/test', app)

module.exports = app

app.listen(app.settings.port, () ->
    console.log "Example app listening at http://localhost:#{app.settings.port}"
)