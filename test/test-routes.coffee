assert = require('chai').assert
request = require('request')
express = require('express')
TokenProvider = require('../app/token-provider')

describe('Routes test suite', ->

    app = null
    server = null
    portNumber = null

    # runs before each test in this suite
    beforeEach((done) ->

        app = express()

        # import the configuration
        require('../app/config')(app)
        portNumber = app.settings.port

        server = app.listen(portNumber, (err, result) ->
            if err then return done(err)

            # get new token provider object
            tokenProvider = new TokenProvider

            # import the endpoints
            require('../app/routes')(app, '/api/', tokenProvider)

            done()
        )
    )

    fakeRoute = '/fake/'
    apiRoute = '/api/'
    fakeAction = 'fakeAction'
    fakeQueryParam = 'fakeQueryParam'

    # Test api route
    it("'#{fakeRoute}' should return a status of 404", (done) ->
        request("http://localhost:#{portNumber}#{fakeRoute}", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 404)
            done()
        )
    )

    # Test Action parameter
    it("'#{apiRoute}?Action=#{fakeAction}' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=#{fakeAction}", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, 'Action parameter value is not recognised')
            done()
        )
    )

    # Test Action=start
    it("'#{apiRoute}?Action=start&#{fakeQueryParam}=2' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=start&#{fakeQueryParam}=2", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, 'Invalid query parameter for start mode')
            done()
        )
    )

    it("'#{apiRoute}?Action=start&matchspeed=0' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=start&matchspeed=0", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, 'Match-speed is not a number larger than or equal to 1')
            done()
        )
    )

    it("'#{apiRoute}?Action=start&matchspeed=hi' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=start&matchspeed=hi", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, 'Match-speed is not a number larger than or equal to 1')
            done()
        )
    )

    it("'#{apiRoute}?Action=start&matchspeed=100' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=start&matchspeed=100", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 200)
            assert.equal(resp.body, JSON.stringify({ tokenId: 0 }))
            done()
        )
    )

    # Test Action=snapshot
    it("'#{apiRoute}?Action=snapshot&#{fakeQueryParam}=2&minute=89' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=snapshot&#{fakeQueryParam}=2&minute=89", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, 'Invalid query parameter(s) for snapshot mode')
            done()
        )
    )

    it("'#{apiRoute}?Action=snapshot&minute=hi&half=first_half' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=snapshot&minute=hi&half=first_half", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, 'hi in first_half is not a valid time combination')
            done()
        )
    )

    it("'#{apiRoute}?Action=snapshot&minute=-1&half=first_half' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=snapshot&minute=-1&half=first_half", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, '-1 in first_half is not a valid time combination')
            done()
        )
    )

    it("'#{apiRoute}?Action=snapshot&minute=46&half=first_half' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=snapshot&minute=46&half=first_half", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, '46 in first_half is not a valid time combination')
            done()
        )
    )

    it("'#{apiRoute}?Action=snapshot&minute=44&half=first_half' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=snapshot&minute=44&half=first_half", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 200)
            done()
        )
    )

    # Test Action=today
    it("'#{apiRoute}?Action=today&#{fakeQueryParam}=0' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=today&#{fakeQueryParam}=0", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, 'Invalid query parameter for today mode')
            done()
        )
    )

    it("'#{apiRoute}?Action=today&tokenId=0' should return a status of 400", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=today&tokenId=0", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 400)
            assert.equal(resp.body, 'Invalid token')
            done()
        )
    )

    it("'#{apiRoute}?Action=today&tokenId=0' should return a status of 400 for an expired token", (done) ->
        multiplier = 60*100*105
        request("http://localhost:#{portNumber}#{apiRoute}?Action=start&matchspeed=#{multiplier}", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 200)
            assert.equal(resp.body, JSON.stringify({ tokenId: 0 }))
            delay(11, () ->
                request("http://localhost:#{portNumber}#{apiRoute}?Action=today&tokenId=0", (err, resp, body) ->
                    if(err) then done(err)
                    assert.equal(resp.statusCode, 400)
                    assert.equal(resp.body, 'Invalid token')
                    done()
                )
            )
        )
    )

    it("'#{apiRoute}?Action=today&tokenId=0' should return a status of 200 for a valid token", (done) ->
        multiplier = 60*50
        request("http://localhost:#{portNumber}#{apiRoute}?Action=start&matchspeed=#{multiplier}", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 200)
            assert.equal(resp.body, JSON.stringify({ tokenId: 0 }))
            delay(241, () ->
                request("http://localhost:#{portNumber}#{apiRoute}?Action=today&tokenId=0", (err, resp, body) ->
                    if(err) then done(err)
                    assert.equal(resp.statusCode, 200)
                    assert.equal(JSON.parse(resp.body)[app.settings.matches][0][app.settings.match_timer], '12')
                    done()
                )
            )
        )
    )

    # Test Action=matches
    it("'#{apiRoute}?Action=matches' should return a status of 200", (done) ->
        request("http://localhost:#{portNumber}#{apiRoute}?Action=matches", (err, resp, body) ->
            if(err) then done(err)
            assert.equal(resp.statusCode, 200)
            settings = app.settings
            expectedMatch0 = {}
            expectedMatch0[settings.home_team] = 'Arsenal'
            expectedMatch0[settings.away_team] = 'West Brom'
            expectedMatch1 = {}
            expectedMatch1[settings.home_team] = 'Aston Villa'
            expectedMatch1[settings.away_team] = 'Burnley'
            assert.deepEqual((JSON.parse(resp.body))[0], expectedMatch0)
            assert.deepEqual((JSON.parse(resp.body))[1], expectedMatch1)
            done()
        )
    )

    # runs after each test in this suite
    afterEach(() ->
        server.close()
    )
)

delay = (ms, func) ->
    setTimeout(func, ms)