TokenProvider = require('../app/token-provider')

MULTIPLIER = 12600 # so that token.get(1 * MULTIPLIER) expires in 500ms

# Test getNewToken, isTokenValid, getTokenMultiplier and getTokenTimestamp on a single valid token request
exports.tokenProviderTest_1 = (test) ->
    tokenProvider = new TokenProvider

    timestamp_1 = Date.now()
    expectedTokenId = 0
    actualTokenId = tokenProvider.getNewToken(2 * MULTIPLIER, timestamp_1)
    test.equal(expectedTokenId, actualTokenId)

    test.ok(tokenProvider.isTokenValid(0))
    test.ok(not tokenProvider.isTokenValid(1))

    expectedMultiplier = 2 * MULTIPLIER
    actualMultiplier = tokenProvider.getTokenMultiplier(0)
    test.equal(expectedMultiplier, actualMultiplier)

    expectedTimestamp = timestamp_1
    actualTimestamp = tokenProvider.getTokenTimestamp(0)
    test.equal(expectedTimestamp, actualTimestamp)

    test.done()

# Test getNewToken and getTokenMultiplier on invalid token requests
exports.tokenProviderTest_2 = (test) ->
    tokenProvider = new TokenProvider

    timestamp = Date.now()
    test.throws(() -> tokenProvider.getNewToken(0, timestamp))
    test.throws(() -> tokenProvider.getNewToken('text', timestamp))
    test.throws(() -> tokenProvider.getTokenMultiplier(10))

    test.done()

# Test getNewToken after multiple valid and invalid token requests
exports.tokenProviderTest_3 = (test) ->
    tokenProvider = new TokenProvider

    actualTokenId_1 = tokenProvider.getNewToken(2 * MULTIPLIER, Date.now())
    actualTokenId_2 = tokenProvider.getNewToken(1 * MULTIPLIER, Date.now())
    actualTokenId_3 = tokenProvider.getNewToken(3 * MULTIPLIER, Date.now())
    test.throws(() -> tokenProvider.getNewToken(0, timestamp_fail))
    actualTokenId_4 = tokenProvider.getNewToken(1 * MULTIPLIER, Date.now())

    expectedTokenId_4 = 3
    test.equal(actualTokenId_4, actualTokenId_4)

    test.done()

# Test that tokens timeout correctly
exports.tokenProviderTest_4 = (test) ->
    tokenProvider = new TokenProvider

    actualTokenId_1 = tokenProvider.getNewToken(2 * MULTIPLIER, Date.now())
    actualTokenId_2 = tokenProvider.getNewToken(1 * MULTIPLIER, Date.now())
    timestamp_3 = Date.now()
    actualTokenId_3 = tokenProvider.getNewToken(3 * MULTIPLIER, timestamp_3)
    actualTokenId_4 = tokenProvider.getNewToken(1 * MULTIPLIER, Date.now())

    # After this delay, actualTokenId_3 will have timed out
    delay MULTIPLIER/4.0, () ->
        test.ok(not tokenProvider.isTokenValid(actualTokenId_3))

        timestamp_5 = Date.now()
        expectedTokenId_5 = actualTokenId_3
        actualTokenId_5 = tokenProvider.getNewToken(10 * MULTIPLIER, timestamp_5)
        test.equal(actualTokenId_5, expectedTokenId_5)

        expected = timestamp_3
        actual = tokenProvider.getTokenTimestamp(3)
        test.equal(actual, expected)

        test.done()

    # After this delay, actualTokenId_3, actualTokenId_1 and actualTokenId_5 will have timed out
    delay 300, () ->
        timestamp_6 = Date.now()
        expected = 0
        actual = tokenProvider.getNewToken(10 * MULTIPLIER, timestamp_6)
        test.equal(actual, expected)

    # After this delay, all tokens will have timed out
    delay 600, () ->
        test.ok(not tokenProvider.isTokenValid(0))
        test.ok(not tokenProvider.isTokenValid(1))

        timestamp_7 = Date.now()
        expectedTokenId_7 = 0
        actualTokenId_7 = tokenProvider.getNewToken(10 * MULTIPLIER, timestamp_7)
        test.equal(actualTokenId_7, expectedTokenId_7)

        test.done()

delay = (ms, func) ->
    setTimeout(func, ms)
