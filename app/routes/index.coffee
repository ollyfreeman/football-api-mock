dataProvider = require('../data-provider')

module.exports = (app, endpoint, tokenProvider) ->

    # Set up the endpoint for GET requests
    app.get(endpoint, (request, response) ->
        try
            switch request.query.Action
                when 'start'
                    responseBody = require('./action-start.coffee')(app, request, tokenProvider)
                when 'today'
                    responseBody = require('./action-today.coffee')(app, request, tokenProvider)
                when 'snapshot'
                    responseBody = require('./action-snapshot.coffee')(app, request)
                when 'matches'
                    responseBody = require('./action-matches.coffee')(app, request)
                else
                    throw new Error('Action parameter value is not recognised')
            response.send(responseBody)
        catch error
            response.status(400).send(error.message)
    )