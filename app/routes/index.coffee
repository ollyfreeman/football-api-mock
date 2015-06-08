dataProvider = require('../data-provider')

module.exports = (app, endpoint, tokenProvider) ->

    # Set up the endpoint for GET requests
    app.get(endpoint, (request, response) ->
        try
            switch request.query.Action
                when 'start'
                    responseBody = responseToActionStart(app, request, tokenProvider)
                when 'today'
                    responseBody = responseToActionToday(app, request, tokenProvider)
                when 'snapshot'
                    responseBody = responseToActionSnapshot(app, request)
                when 'matches'
                    responseBody = responseToActionMatches(app, request)
                else
                    throw new Error('Action parameter value is not recognised')
            response.send(responseBody)
        catch error
            response.status(400).send(error.message)
    )

# Returns the response body to an '/api/?Action=start' request
responseToActionStart = (app, request, tokenProvider) ->
    matchspeed = request.query.matchspeed
    throw new Error('Invalid query parameter for start mode') if not matchspeed

    tokenId = tokenProvider.getNewToken(matchspeed, Date.now())
    return { tokenId: tokenId }

# Returns the response body to an '/api/?Action=start' request
responseToActionToday = (app, request, tokenProvider) ->
    tokenId = request.query.tokenId
    throw new Error('Invalid query parameter for today mode') if not tokenId

    if tokenProvider.isTokenValid(tokenId)
        multiplier = tokenProvider.getTokenMultiplier(tokenId)
        timestamp = tokenProvider.getTokenTimestamp(tokenId)
        [minute, half] = getMinuteAndHalf(app, timestamp, Date.now(), multiplier)
        return dataProvider.dataAtTime(app, minute, half)
    else
        throw new Error('Invalid token')

# Returns the response body to an '/api/?Action=snapshot' request
responseToActionSnapshot = (app, request) ->
    minute = request.query.minute
    half = request.query.half
    throw new Error('Invalid query parameter(s) for snapshot mode') if not (minute and half)

    throw new Error("#{minute} in #{half} is not a valid time combination") if not isTimeValid(app, minute, half)

    return dataProvider.dataAtTime(app, minute, half)

# Returns the response body to an '/api/?Action=matches' request
responseToActionMatches = (app) ->
    return dataProvider.getMatches(app)

# Returns the minute and the half that the match is in, given the start and current timestamps.
# If the timestamps do not give a valid minute-half combination, an error is thrown.
getMinuteAndHalf = (app, startTimestamp, currentTimestamp, multiplier) ->
    simulationMinutesSinceStart = parseInt(((currentTimestamp - startTimestamp)/(1000*60))*multiplier)
    if 0 <= simulationMinutesSinceStart <= 45
        return [simulationMinutesSinceStart, app.settings.FIRST_HALF]
    else if 46 <= simulationMinutesSinceStart <= 60
        return [45, app.settings.FIRST_HALF]
    else if 61 <= simulationMinutesSinceStart <= 106
        return [simulationMinutesSinceStart - 16, app.settings.SECOND_HALF]
    else if 106 >= simulationMinutesSinceStart
        return [90, app.settings.SECOND_HALF]

# Returns whether minute is a valid minute in half
# where the first half can be 0-45mins (inclusive), and the second half can be 45-90mins (inclusive)
isTimeValid = (app, minute, half) ->
    isFirstHalf = half is app.settings.FIRST_HALF and 0 <= minute <= 45
    isSecondHalf = half is app.settings.SECOND_HALF and 45 <= minute <= 90

    if not (isFirstHalf or isSecondHalf) then return false else return true