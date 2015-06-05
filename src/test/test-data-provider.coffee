require('it-each')({ testPerIteration: true })
chai = require('chai')
assert = chai.assert

fs = require('fs')
fileLoader = require('../app/file-loader')
dataProvider = require('../app/data-provider')

configFilePath = './etc/config/data-format.yaml'
dataFilePath = './etc/test/test-match-reports.yaml'
testResources = './etc/test/'

describe('Data provider test suite', ->

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

    it.each(testConfigs, 'dataAtTime gives correct data at %s in %s', ['minute', 'half'], (testConfig) ->
        matchReportFile = "test-match-reports-formatted-#{testConfig.minute}min-#{testConfig.half}.json"
        expected = fileLoader.loadJSON("#{testResources}#{matchReportFile}", 'utf8')
        actual = dataProvider.dataAtTime(app, testConfig.minute, testConfig.half)
        assert.deepEqual(actual, expected)
    )

    # Test that correct error messagge is received
    testConfigs = [
        {   minute: -1, half: settings.FIRST_HALF },
        {   minute: 46, half: settings.FIRST_HALF },
        {   minute: 44, half: settings.SECOND_HALF },
        {   minute: 91, half: settings.SECOND_HALF },
        {   minute: 44, half: 'fake' },
    ]

    it.each(testConfigs, 'dataAtTime gives correct error at %s in %s', ['minute', 'half'], (testConfig) ->
        expectedError = "Error: #{testConfig.minute} in #{testConfig.half} is not a valid time combination"
        expected = { ERROR: expectedError, ServerName: 'Football-API-Mock'}
        actual = dataProvider.dataAtTime(app, testConfig.minute, testConfig.half)
        assert.deepEqual(actual, expected)
    )
)