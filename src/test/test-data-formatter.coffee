fs = require('fs')
fileLoader = require('../../build/app/file-loader')
dataFormatter = require('../../build/app/data-formatter')

testResources = './etc/test/'
configFilePath = './etc/data-format-config.json'

exports.dataFormatterTest = (test) ->
    # Test standard functionality
    formattedJSON = fileLoader.loadJSON("#{testResources}test-match-reports-formatted.json")
    unformattedJSON = fileLoader.loadJSON("#{testResources}test-match-reports-unformatted.json")
    config = fileLoader.loadJSON(configFilePath)

    expected = formattedJSON
    actual = dataFormatter.format(unformattedJSON, config)
    test.deepEqual(actual, expected)

    test.done()