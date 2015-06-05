express = require('express')
TokenProvider = require('./token-provider')

# if this file is being run directly
if not module.parent

    # create the app
    app = express()

    # import the configuration
    require('./config')(app)

    # set the app to list on the given port
    app.listen app.settings.port, () ->

        # get new token provider object
        tokenProvider = new TokenProvider

        # import the endpoints
        require('./routes')(app, '/api/', tokenProvider)

        console.log "Listening at http://localhost:#{app.settings.port}"

module.exports = app