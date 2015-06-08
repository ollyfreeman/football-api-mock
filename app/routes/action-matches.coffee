dataProvider = require('../data-provider')

# Returns the response body to an '/api/?Action=matches' request
module.exports = (app) ->
    return dataProvider.getMatches(app)