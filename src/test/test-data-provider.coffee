fs = require('fs')
fileLoader = require('../../build/app/file-loader')
dataProvider = require('../../build/app/data-provider')

configFilePath = './etc/data-format-config.yaml'
testResources = './etc/test/'

exports.dataAtTimeTest = (test) ->
    dfConfig = fileLoader.loadYAML(configFilePath)
    unformattedData = fileLoader.loadYAML("#{testResources}match-reports-1.yaml")

    # Test standard functionality
    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-0min-fh.json", 'utf8'))
    actual = dataProvider.dataAtTime(unformattedData, 0, dfConfig.FIRST_HALF, dfConfig)
    test.deepEqual(actual, expected)

    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-15min-fh.json", 'utf8'))
    actual = dataProvider.dataAtTime(unformattedData, 15, dfConfig.FIRST_HALF, dfConfig)
    test.deepEqual(actual, expected)

    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-45min-fh.json", 'utf8'))
    actual = dataProvider.dataAtTime(unformattedData, 45, dfConfig.FIRST_HALF, dfConfig)
    test.deepEqual(actual, expected)

    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-45min-sh.json", 'utf8'))
    actual = dataProvider.dataAtTime(unformattedData, 45, dfConfig.SECOND_HALF, dfConfig)
    test.deepEqual(actual, expected)

    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-90min-sh.json", 'utf8'))
    actual = dataProvider.dataAtTime(unformattedData, 90, dfConfig.SECOND_HALF, dfConfig)
    test.deepEqual(actual, expected)

    # Test that an error is thrown if an invalid input is given
    test.throws(() -> dataProvider.dataAtTime(unformattedData, -1, dfConfig.FIRST_HALF, dfConfig))
    test.throws(() -> dataProvider.dataAtTime(unformattedData, 46, dfConfig.FIRST_HALF, dfConfig))
    test.throws(() -> dataProvider.dataAtTime(unformattedData, 44, dfConfig.SECOND_HALF, dfConfig))
    test.throws(() -> dataProvider.dataAtTime(unformattedData, 91, dfConfig.SECOND_HALF, dfConfig))
    test.throws(() -> dataProvider.dataAtTime(unformattedData, 44, 'fake', dfConfig))

    test.done()