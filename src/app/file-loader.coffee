yaml = require('js-yaml')
fs = require('fs')

exports.loadYAML = (filepath) ->
    try
        doc = yaml.safeLoad(fs.readFileSync(filepath, 'utf8'))
        return doc
    catch e
        throw new Error("Error while loading #{filepath} as YAML")

exports.loadJSON = (filepath) ->
    try
        doc = JSON.parse(fs.readFileSync(filepath, 'utf8'))
        return doc
    catch e
        console.log e
        throw new Error("Error while loading #{filepath} as JSON")
