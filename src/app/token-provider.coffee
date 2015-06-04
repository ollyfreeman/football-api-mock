class TokenProvider

    ONE_HUNDRED_AND_FIVE_MINS = 105*60*1000.0

    constructor: ->
        @tokens = {}

    getNewToken : (multiplier, timestamp) ->
        throw new Error('Multiplier is not larger than or equal to 1') if not (multiplier >= 1)
        nextTokenId = getNextTokenId(@tokens)
        @tokens[nextTokenId] = { multiplier: multiplier, timestamp: timestamp }
        ((nextTokenId) => # TODO: do i need an IIF here?
            delay(ONE_HUNDRED_AND_FIVE_MINS/multiplier, () =>
                delete @tokens[nextTokenId])
        )(nextTokenId)
        return nextTokenId

    isTokenValid: (tokenId) =>
        @tokens.hasOwnProperty(tokenId)

    getTokenMultiplier: (tokenId) =>
        @tokens[tokenId].multiplier

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

