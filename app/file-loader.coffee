yaml = require('js-yaml')
fs = require('fs')

# Load a YAML file
exports.loadYAML = (filepath) ->
    try
        doc = yaml.safeLoad(fs.readFileSync(filepath, 'utf8'))
        return doc
    catch error
        throw new Error("Error while loading #{filepath} as YAML")

# Load a JSON file
exports.loadJSON = (filepath) ->
    try
        doc = JSON.parse(fs.readFileSync(filepath, 'utf8'))
        return doc
    catch error
        throw new Error("Error while loading #{filepath} as JSON")
