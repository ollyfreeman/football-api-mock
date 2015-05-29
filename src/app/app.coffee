fs = require('fs')
fileLoader = require('../../build/app/file-loader')
dataFormatter = require('../../build/app/data-formatter')

testResources = './etc/test/'
configFilePath = './etc/data-format-config.json'

unformattedJSON = fileLoader.loadJSON("#{testResources}test-match-reports-unformatted.json")
config = fileLoader.loadJSON(configFilePath)
formattedJSON = dataFormatter.format(unformattedJSON, config)
console.log formattedJSON