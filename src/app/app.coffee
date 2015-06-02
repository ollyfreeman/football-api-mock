fileLoader = require('../../build/app/file-loader')
dataProvider = require('../../build/app/data-provider')

testResources = './etc/test/'
configFilePath = './etc/data-format-config.yaml'

dfConfig = fileLoader.loadYAML(configFilePath)
unformattedJSON = fileLoader.loadYAML("#{testResources}match-reports-1.yaml")
providedData = dataProvider.dataAtTime(unformattedJSON, 0, dfConfig.FIRST_HALF, dfConfig)
console.log providedData