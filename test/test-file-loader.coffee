assert = require('chai').assert

fs = require('fs')
fileLoader = require('../app/file-loader')

testResources = './etc/test/'


describe('File loader test suite', ->

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

    it("loadYAML should load '#{testResources}test-file-loader.yaml' correctly", () ->
        actual = fileLoader.loadYAML("#{testResources}test-file-loader.yaml")
        assert.deepEqual(actual,expected)
    )

    it("loadYAML should throw and error with input: '#{testResources}fake.yaml'", () ->
        assert.throws(() -> fileLoader.loadYAML("#{testResources}fake.yaml"))
    )

    it("loadJSON should load '#{testResources}test-file-loader.json' correctly", () ->
        actual = fileLoader.loadJSON("#{testResources}test-file-loader.json")
        assert.deepEqual(actual,expected)
    )

    it("loadJSON should throw and error with input: '#{testResources}fake.json'", () ->
        assert.throws(() -> fileLoader.loadJSON("#{testResources}fake.json"))
    )
)