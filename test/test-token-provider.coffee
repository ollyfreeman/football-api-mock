assert = require('chai').assert

TokenProvider = require('../app/token-provider')

MULTIPLIER = 126000 # so that token.get(1 * MULTIPLIER) expires in 50ms

delay = (ms, func) ->
    setTimeout(func, ms)

describe('Token provider test suite', ->

    testDescription =
        'Test getNewToken, isTokenValid, getTokenMultiplier
        and getTokenTimestamp on a single valid token request'
    it(testDescription, () ->
        tokenProvider = new TokenProvider

        timestamp_1 = Date.now()
        expectedTokenId = 0
        actualTokenId = tokenProvider.getNewToken(2 * MULTIPLIER, timestamp_1)
        assert.equal(expectedTokenId, actualTokenId)

        assert.ok(tokenProvider.isTokenValid(0))
        assert.ok(not tokenProvider.isTokenValid(1))

        expectedMultiplier = 2 * MULTIPLIER
        actualMultiplier = tokenProvider.getTokenMultiplier(0)
        assert.equal(expectedMultiplier, actualMultiplier)

        expectedTimestamp = timestamp_1
        actualTimestamp = tokenProvider.getTokenTimestamp(0)
        assert.equal(expectedTimestamp, actualTimestamp)
    )

    it('Test getNewToken and getTokenMultiplier on invalid token requests', () ->
        tokenProvider = new TokenProvider

        timestamp = Date.now()
        assert.throws(() -> tokenProvider.getNewToken(0, timestamp))
        assert.throws(() -> tokenProvider.getNewToken('text', timestamp))
        assert.throws(() -> tokenProvider.getTokenMultiplier(10))
    )

    it('Test getNewToken after multiple valid and invalid token requests', () ->
        tokenProvider = new TokenProvider

        actualTokenId_1 = tokenProvider.getNewToken(2 * MULTIPLIER, Date.now())
        actualTokenId_2 = tokenProvider.getNewToken(1 * MULTIPLIER, Date.now())
        actualTokenId_3 = tokenProvider.getNewToken(3 * MULTIPLIER, Date.now())
        assert.throws(() -> tokenProvider.getNewToken(0, timestamp_fail))
        actualTokenId_4 = tokenProvider.getNewToken(1 * MULTIPLIER, Date.now())

        expectedTokenId_4 = 3
        assert.equal(actualTokenId_4, actualTokenId_4)
    )

    it('Test that tokens timeout correctly', (done) ->
        tokenProvider = new TokenProvider

        actualTokenId_1 = tokenProvider.getNewToken(2 * MULTIPLIER, Date.now())
        actualTokenId_2 = tokenProvider.getNewToken(1 * MULTIPLIER, Date.now())
        timestamp_3 = Date.now()
        actualTokenId_3 = tokenProvider.getNewToken(3 * MULTIPLIER, timestamp_3)
        actualTokenId_4 = tokenProvider.getNewToken(1 * MULTIPLIER, Date.now())

        # After this delay, actualTokenId_3 will have timed out
        delay MULTIPLIER/4.0, () ->
            assert.ok(not tokenProvider.isTokenValid(actualTokenId_3))

            timestamp_5 = Date.now()
            expectedTokenId_5 = actualTokenId_3
            actualTokenId_5 = tokenProvider.getNewToken(10 * MULTIPLIER, timestamp_5)
            assert.equal(actualTokenId_5, expectedTokenId_5)

            expected = timestamp_3
            actual = tokenProvider.getTokenTimestamp(3)
            assert.equal(actual, expected)

        # After this delay, actualTokenId_3, actualTokenId_1 and actualTokenId_5 will have timed out
        delay 30, () ->
            timestamp_6 = Date.now()
            expected = 0
            actual = tokenProvider.getNewToken(10 * MULTIPLIER, timestamp_6)
            assert.equal(actual, expected)

        # After this delay, all tokens will have timed out
        delay 60, () ->
            assert.ok(not tokenProvider.isTokenValid(0))
            assert.ok(not tokenProvider.isTokenValid(1))

            timestamp_7 = Date.now()
            expectedTokenId_7 = 0
            actualTokenId_7 = tokenProvider.getNewToken(10 * MULTIPLIER, timestamp_7)
            assert.equal(actualTokenId_7, expectedTokenId_7)

            done()
    )
)