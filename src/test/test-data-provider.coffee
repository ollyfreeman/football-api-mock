fs = require('fs')
fileLoader = require('../app/file-loader')
dataProvider = require('../app/data-provider')

configFilePath = './etc/data-format-config.yaml'
dataFilePath = './etc/test/test-match-reports.yaml'
testResources = './etc/test/'

exports.dataAtTimeTest = (test) ->
    settings = fileLoader.loadYAML(configFilePath)
    unformattedData = fileLoader.loadYAML(dataFilePath)
    app = {}
    app.settings = settings
    app.settings.data = unformattedData

    # Test standard functionality
    testConfigs = [
        {   minute: 0, half: settings.FIRST_HALF },
        {   minute: 15, half: settings.FIRST_HALF },
        {   minute: 45, half: settings.FIRST_HALF },
        {   minute: 45, half: settings.SECOND_HALF },
        {   minute: 90, half: settings.SECOND_HALF }
    ]

    for testConfig in testConfigs
        expected = fileLoader.loadYAML("#{testResources}test-match-reports-formatted-#{testConfig.minute}min-#{testConfig.half}.json", 'utf8')
        actual = dataProvider.dataAtTime(app, testConfig.minute, testConfig.half)
        test.deepEqual(actual, expected)

    # Test that an error is thrown if an invalid input is given
    testConfigs = [
        {   minute: -1, half: settings.FIRST_HALF },
        {   minute: 46, half: settings.FIRST_HALF },
        {   minute: 44, half: settings.SECOND_HALF },
        {   minute: 91, half: settings.SECOND_HALF },
        {   minute: 44, half: 'fake' },
    ]

    for testConfig in testConfigs
        expected = { ERROR: "Error: #{testConfig.minute} in #{testConfig.half} is not a valid time combination", ServerName: 'Football-API-Mock'}
        actual = dataProvider.dataAtTime(app, testConfig.minute, testConfig.half)
        test.deepEqual(actual, expected)

    test.done()