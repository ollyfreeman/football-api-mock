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
    minute = request.query.minute
    half = request.query.half
    throw new Error('Invalid query parameter(s) for snapshot mode') if not (minute and half)

    if not isTimeValid(app, minute, half)
        throw new Error("#{minute} in #{half} is not a valid time combination")

    return dataProvider.dataAtTime(app, minute, half)

responseToActionStart = (app, request, tokenProvider) ->
    matchspeed = request.query.matchspeed
    throw new Error('Invalid query parameter for start mode') if not matchspeed

    tokenId = tokenProvider.getNewToken(matchspeed, Date.now())
    return { tokenId: tokenId }

responseToActionToday = (app, request, tokenProvider) ->
    tokenId = request.query.tokenId
    throw new Error('Invalid query parameter for today mode') if not tokenId

    if tokenProvider.isTokenValid(tokenId)
        multiplier = tokenProvider.getTokenMultiplier(tokenId)
        timestamp = tokenProvider.getTokenTimestamp(tokenId)
        [minute, half] = getMinuteAndHalf(app, timestamp, Date.now(), multiplier)
        responseBody = dataProvider.dataAtTime(app, minute, half)
    else
        throw new Error('Invalid token')

# Returns whether minute is a valid minute in half
# where the first half can be 0-45mins (inclusive), and the second half can be 45-90mins (inclusive)
isTimeValid = (app, minute, half) ->
    isFirstHalf = half is app.settings.FIRST_HALF and 0 <= minute <= 45
    isSecondHalf = half is app.settings.SECOND_HALF and 45 <= minute <= 90

    if not (isFirstHalf or isSecondHalf)
        return false
    return true

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
