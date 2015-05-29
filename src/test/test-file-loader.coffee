fs = require('fs')
fileLoader = require('../../build/app/file-loader')

testResources = './etc/test/'

expected = {
    key: 'value',
    another_key: 'Another value.',
    a_number_value: 100,
    a_list: {
        key: 'value',
        another_key: 'Another value.',
        a_nested_list: {
            key: 'value'
        }
    },
    an_array: [
        'Item 1',
        'Item 2'
    ]
}

exports.loadYAMLTest = (test) ->
    # Test standard functionality
    actual = fileLoader.loadYAML("#{testResources}test-file-loader.yaml")
    test.deepEqual(actual, expected)

    # Test that an error is thrown if an invalid input is given
    test.throws(() ->yamlReader.read("#{testResources}fake.yaml"))

    test.done()

exports.loadJSONTest = (test) ->
    # Test standard functionality
    actual = fileLoader.loadJSON("#{testResources}test-file-loader.json")
    test.deepEqual(actual, expected)

    # Test that an error is thrown if an invalid input is given
    test.throws(() ->yamlReader.read("#{testResources}fake.json"))

    test.done()

