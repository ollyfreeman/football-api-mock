fs = require('fs')
dataProvider = require('../../build/app/data-provider')

configFilePath = './etc/data-format-config.json'
testResources = './etc/test/'
testMatchReportsAt0mins = './etc/test/test-match-reports-0min.json'

exports.dataAtTimeTest = (test) ->
    config = JSON.parse(fs.readFileSync(configFilePath, 'utf8'))
    formattedData = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted.json", 'utf8'))

    # Test standard functionality
    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-0min-fh.json", 'utf8'))
    actual = dataProvider.dataAtTime(formattedData, 0, 'first_half', config)
    test.deepEqual(actual, expected)

    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-15min-fh.json", 'utf8'))
    actual = dataProvider.dataAtTime(formattedData, 15, 'first_half', config)
    test.deepEqual(actual, expected)

    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-45min-fh.json", 'utf8'))
    actual = dataProvider.dataAtTime(formattedData, 45, 'first_half', config)
    test.deepEqual(actual, expected)

    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-45min-sh.json", 'utf8'))
    actual = dataProvider.dataAtTime(formattedData, 45, 'second_half', config)
    test.deepEqual(actual, expected)

    expected = JSON.parse(fs.readFileSync("#{testResources}test-match-reports-formatted-90min-sh.json", 'utf8'))
    actual = dataProvider.dataAtTime(formattedData, 90, 'second_half', config)
    test.deepEqual(actual, expected)

    # Test that an error is thrown if an invalid input is given
    test.throws(dataProvider.dataAtTime(formattedData, -1, 'first_half', config))
    test.throws(dataProvider.dataAtTime(formattedData, 46, 'first_half', config))
    test.throws(dataProvider.dataAtTime(formattedData, 44, 'second_half', config))
    test.throws(dataProvider.dataAtTime(formattedData, 91, 'second_half', config))
    test.throws(dataProvider.dataAtTime(formattedData, 44, 'fake', config))

    test.done()