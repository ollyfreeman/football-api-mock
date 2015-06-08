# Returns the response body to an '/api/?Action=start' request
module.exports = (app, request, tokenProvider) ->
    matchspeed = request.query.matchspeed
    throw new Error('Invalid query parameter for start mode') if not matchspeed

    tokenId = tokenProvider.getNewToken(matchspeed, Date.now())
    return { tokenId: tokenId }