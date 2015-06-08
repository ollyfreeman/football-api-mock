require('it-each')({ testPerIteration: true })
assert = require('chai').assert

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

    # Test getMatches
    it('getMatches should return array of matches, listing home and away teams', () ->
        expectedMatch0 = {}
        expectedMatch0[settings.home_team] = 'Arsenal'
        expectedMatch0[settings.away_team] = 'West Brom'
        expectedMatch1 = {}
        expectedMatch1[settings.home_team] = 'Aston Villa'
        expectedMatch1[settings.away_team] = 'Burnley'
        expected = [ expectedMatch0, expectedMatch1 ]
        actual = dataProvider.getMatches(app)
        assert.deepEqual(actual,expected)
    )

    # Test dataAtTime
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
)