football-api-mock
=================

This server is inteded to mock the functionality of the `football-api.com` API, which returns the live status of
matches that are currently in progress, for a given competition (e.g. the English Premier League).

An API call to the `football-api.com` API for the current scores in an EPL match would be:
`http://football-api.com/api/?Action=today&APIKey={my_api_key}&comp_id=1204`.

The mock server will not require authentication, and the competition will always be the EPL (the server returns
the status of the EPL matches played on Sunday 24th May 2015 - see `etc/football-api.json` for a response that was obtained from this URL
at 16:40 GMT on this date), so a typical call to the mock server will be:
`http://mydomain.com/api/?Action=today`.

However, since the intention is for this mock server to provide the functionality of the `football-api.com` API
*on demand*, it provides the functionality to control when the simulation of the matches start, at at what 'speed' the matches should
be simulated - e.g. '1x speed', '10x speed' etc.

In addition to the above functionality, the mock server will also return the status of the matches at a *specified*
time during the matches. Note that this functionality is not present in the `football-api.com` API. A typical call of this type to
the mock server will be:
`http://mydomain.com/api/?Action=snapshot&minute=32&half=first_half`.

Note: in the simulations, it is assumed that there is no injury time, so the matches occur in lockstep, with exactly
45 minutes for each half, with exactly 15 minutes break for half-time.

##Requirements

Install `coffeescript` with `npm install -g coffee-script`

##Setup

Clone the repo, and install with `npm install`.

##Lint and test

Running `grunt` will lint all `.coffee` files and run all unit tests.

##Run server application

Start the node server with `npm start`.

##Endpoints
###`Action=start`
e.g. `http://mydomain.com/api/?Action=start&multiplier=10`

####Parameters:

`multiplier` - a number that is larger than or equal to `1`. For example, a multiplier of `60` will result in a match simulation that
lasts 105 seconds instead of 105 minutes (where 105 minutes derives from 2 halves of 45 minutes, plus 15 minutes during half-time).

####Return value:

e.g. `{ "tokenId": 5 }` - a token that can be used to query the simulation that was started by the API call.

###`Action=today`
e.g. `http://mydomain.com/api/?Action=today&tokenId=5`

####Parameters:

`tokenId` - a token (returned from a call to the `start` action) that represents the simulation that you wish to query.

####Return values:

`400` - a bad request will be returned if the token is not valid - i.e. if the match simulation identified by that token has ended.

`200` - a JSON containing the match data that represents the states of the matches at the current point in the simulation.

###`Action=snapshot`
e.g. `http://mydomain.com/api/?Action=snapshot&half=first_half&minute=34`

####Parameters:

`half` - either `first_half` or `second_half`

`minute` - an integer between `0` and `45` if `half=first_half`, or between `45` and `90` if `half=second_half`

####Return values:

`400` - a bad request will be returned if the parameter values are not valid, as specified above.

`200` - a JSON containing the match data that represents the states of the matches at the specified point, of the same form as
the JSON returned by the `today` action.

