dataProvider = require('../data-provider')

# Returns the response body to an '/api/?Action=snapshot' request
module.exports = (app, request) ->
    minute = request.query.minute
    half = request.query.half
    throw new Error('Invalid query parameter(s) for snapshot mode') if not (minute and half)

    throw new Error("#{minute} in #{half} is not a valid time combination") if not isTimeValid(app, minute, half)

    return dataProvider.dataAtTime(app, minute, half)

# Returns whether minute is a valid minute in half
# where the first half can be 0-45mins (inclusive), and the second half can be 45-90mins (inclusive)
isTimeValid = (app, minute, half) ->
    isFirstHalf = half is app.settings.FIRST_HALF and 0 <= minute <= 45
    isSecondHalf = half is app.settings.SECOND_HALF and 45 <= minute <= 90

    if not (isFirstHalf or isSecondHalf) then return false else return true