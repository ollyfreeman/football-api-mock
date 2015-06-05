fileLoader = require('../file-loader')

generalConfigFilePath = './etc/config/general.yaml'
dataConfigFilePath = './etc/config/data-format.yaml'
dataFilePath = './etc/match-reports-1.yaml'

module.exports = (app) ->

    # Load general config
    generalConfig = fileLoader.loadYAML(generalConfigFilePath)
    app.set(generalSetting, generalConfig[generalSetting]) for generalSetting of generalConfig

    # Load data-format config
    dataFormatConfig = fileLoader.loadYAML(dataConfigFilePath)
    app.set(dataFormatSetting, dataFormatConfig[dataFormatSetting]) for dataFormatSetting of dataFormatConfig

    # Load match data
    unformattedData = fileLoader.loadYAML(dataFilePath)
    app.set('data', unformattedData)