# TokenProvider manages the created and validation of tokens,
# as well as the retrieval of a valid token
class TokenProvider

    ONE_HUNDRED_AND_FIVE_MINS = 105*60*1000

    constructor: () ->
        @tokens = {}

    # Creates a token with id as the lowest value positive integer that is not already a valid token
    # The created token has multiplier and timestamp associated with it
    # The created token expires after 105mins of simulated game time, i.e. 105mins/multiplier of real time
    getNewToken : (multiplier, timestamp) ->
        throw new Error('Match-speed is not a number larger than or equal to 1') if not (multiplier >= 1)
        nextTokenId = getNextTokenId(@tokens)
        @tokens[nextTokenId] = { multiplier: multiplier, timestamp: timestamp }
        ((nextTokenId) =>
            delay(ONE_HUNDRED_AND_FIVE_MINS/(multiplier*0.9), () =>
                delete @tokens[nextTokenId])
        )(nextTokenId)
        return nextTokenId

    # Returns whether the token with tokenId is valid
    isTokenValid: (tokenId) =>
        @tokens.hasOwnProperty(tokenId)

    # Returns the multiplier associated with tokenId
    getTokenMultiplier: (tokenId) =>
        @tokens[tokenId].multiplier

    # Returns the timestamp associated with tokenId
    getTokenTimestamp: (tokenId) =>
        @tokens[tokenId].timestamp

module.exports = TokenProvider

getNextTokenId = (tokens) ->
    if isEmpty(tokens)
        return 0
    else
        keys = []
        keys.push(key) for own key of tokens
        keys.sort()
        return getSmallestAbsentInteger(keys)

getSmallestAbsentInteger = (list) ->
    if list[0] > 0
        return 0
    else
        previous = 0
        index = 1
        while index < list.length and previous + 1 is parseInt(list[index])
            previous += 1
            index += 1
        return parseInt(list[index-1]) + 1

delay = (ms, func) ->
    setTimeout func, ms

isEmpty = (obj) ->
    return Object.keys(obj).length is 0

