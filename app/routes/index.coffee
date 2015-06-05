dataProvider = require('../data-provider')

module.exports = (app, endpoint, tokenProvider) ->

    app.get(endpoint, (request, response) ->
        try
            switch request.query.Action
                when 'snapshot'
                    responseBody = responseToActionSnapshot(app, request)
                when 'start'
                    responseBody = responseToActionStart(app, request, tokenProvider)
                when 'today'
                    responseBody = responseToActionToday(app, request, tokenProvider)
                else
                    throw new Error('Action parameter value is not recognised')
            response.send(responseBody)
        catch error
            response.status(400).send(error.message)
  )

responseToActionSnapshot = (app, request) ->
    return dataProvider.dataAtTime(app, request.query.minute, request.query.half)

responseToActionStart = (app, request, tokenProvider) ->
    tokenId = tokenProvider.getNewToken(request.query.matchspeed, Date.now())
    return { tokenId: tokenId }

responseToActionToday = (app, request, tokenProvider) ->
    tokenId = request.query.tokenId
    if tokenProvider.isTokenValid(tokenId)
        multiplier = tokenProvider.getTokenMultiplier(tokenId)
        timestamp = tokenProvider.getTokenTimestamp(tokenId)
        [minute, half] = getMinuteAndHalf(app, timestamp, Date.now(), multiplier)
        responseBody = dataProvider.dataAtTime(app, minute, half)
    else
        throw new Error('Token is invalid')

getMinuteAndHalf = (app, startTimestamp, currentTimestamp, multiplier) ->
    simulationMinutesSinceStart = parseInt(((currentTimestamp - startTimestamp)/(1000.0*60))*multiplier)
    if 0 <= simulationMinutesSinceStart < 45
        return [simulationMinutesSinceStart, app.settings.FIRST_HALF]
    else if 45 <= simulationMinutesSinceStart < 60
        return [45, app.settings.FIRST_HALF]
    else if 60 <= simulationMinutesSinceStart < 90
        return [simulationMinutesSinceStart - 15, app.settings.SECOND_HALF]
    else if simulationMinutesSinceStart is 90
        return [90, app.settings.SECOND_HALF]
    else
        # This should never be reached, since token should have been invalidated
        console.log('SMELL: This statement should never be reached')
        throw new Error('Timestamp of token is expired')
