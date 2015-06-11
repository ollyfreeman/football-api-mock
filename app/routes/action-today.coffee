dataProvider = require('../data-provider')

# Returns the response body to an '/api/?Action=start' request
module.exports = (app, request, tokenProvider) ->
    tokenId = request.query.tokenId
    throw new Error('Invalid query parameter for today mode') if not tokenId

    if tokenProvider.isTokenValid(tokenId)
        multiplier = tokenProvider.getTokenMultiplier(tokenId)
        timestamp = tokenProvider.getTokenTimestamp(tokenId)
        [minute, half] = getMinuteAndHalf(app, timestamp, Date.now(), multiplier)
        return dataProvider.dataAtTime(app, minute, half)
    else
        throw new Error('Invalid token')

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
    else if simulationMinutesSinceStart > 106
        return [90, app.settings.SECOND_HALF]