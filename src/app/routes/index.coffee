dataProvider = require('../data-provider')

module.exports = (endpoint, app) ->

  app.get(endpoint, (request, response) ->
    responseBody = dataProvider.dataAtTime(app, request.query.minute, request.query.half)
    response.send(responseBody)
  )