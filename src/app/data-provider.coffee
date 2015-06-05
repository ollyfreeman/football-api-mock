fileLoader = require('./file-loader')

exports.dataAtTime = (app, minute, half) ->

    try
        outputData = {}
        settings = app.settings
        throw new Error("#{minute} in #{half} is not a valid time combination") if not isTimeValid(minute, half, settings)

        outputData[settings.matches] = []
        unformattedData = settings.data

        for match in unformattedData.matches
            outputMatch = createMatchObject(match, minute, half, settings)
            outputData[settings.matches].push(outputMatch)

        outputData[settings.error] = settings.NO_ERROR
    #TODO: should this be an error in a 200 response, or a 400 response
    catch error
        outputData[settings.error] = '' + error
    finally
        outputData[settings.server] = settings.FOOTBALL_API_MOCK
        return outputData

# Creates a match object from the unformatted (imported from YAML) state
# according to the provided minute and half
createMatchObject = (unformattedMatch, minute, half, settings) ->
    outputMatch = {}
    outputEvents = []

    goals = {}
    goals[settings.HOME_TEAM] = 0
    goals[settings.AWAY_TEAM] = 0

    outputMatch[settings.home_team] = unformattedMatch.home_team
    outputMatch[settings.away_team] = unformattedMatch.away_team

    first_half_events = getEventsFromHalf(unformattedMatch, minute, settings.FIRST_HALF, settings)
    outputEvents.push(formatEvent(unformattedEvent, unformattedMatch, goals, settings)) for unformattedEvent in first_half_events
    outputMatch[settings.ht_score] = if minute >= 45 then "[#{goals[settings.HOME_TEAM]}-#{goals[settings.AWAY_TEAM]}]" else settings.SCORE_NOT_REACHED

    if half is settings.SECOND_HALF
        second_half_events = getEventsFromHalf(unformattedMatch, minute, settings.SECOND_HALF, settings)
        outputEvents.push(formatEvent(unformattedEvent, unformattedMatch, goals, settings)) for unformattedEvent in second_half_events
    outputMatch[settings.ft_score] = if minute >= 90 then "[#{goals[settings.HOME_TEAM]}-#{goals[settings.AWAY_TEAM]}]" else settings.SCORE_NOT_REACHED

    outputMatch[settings.match_time] = if minute < 90 then "#{minute}" else settings.MATCH_FINISHED
    outputMatch[settings.match_home_team_score] = "#{goals[settings.HOME_TEAM]}"
    outputMatch[settings.match_away_team_score] = "#{goals[settings.AWAY_TEAM]}"

    isHalfTime = half is settings.FIRST_HALF and minute >= 45
    isFullTime = half is settings.SECOND_HALF and minute >= 90
    outputMatch[settings.match_status] = if isHalfTime then settings.HALF_TIME else if isFullTime then settings.FULL_TIME else "#{minute}"

    outputMatch[settings.events] = outputEvents

    return outputMatch

# Formats an event (goal, yellow card etc) from an object from the unformatted (imported from YAML) state
# and updates the goals object accordingly
formatEvent = (unformattedEvent, unformattedMatch, goals, settings) ->
    formattedEvent = {}

    formattedEvent[settings.type] = unformattedEvent.type
    formattedEvent[settings.time] = '' + unformattedEvent.time
    formattedEvent[settings.player] = unformattedEvent.player
    formattedEvent[settings.team] = if unformattedEvent.team is unformattedMatch.home_team then settings.HOME_TEAM else settings.AWAY_TEAM

    if unformattedEvent.type is settings.GOAL
        goals[formattedEvent[settings.team]] += 1
        formattedEvent[settings.event_result] = "[#{goals[settings.HOME_TEAM]} - #{goals[settings.AWAY_TEAM]}]"
    else
        formattedEvent[settings.event_result] = settings.NO_EFFECT_ON_SCORE

    return formattedEvent


# Returns whether minute is a valid minute in half
# where the first half can be 0-45mins (inclusive), and the second half can be 45-90mins (inclusive)
isTimeValid = (minute, half, settings) ->
    if not ((half is settings.FIRST_HALF and 0 <= minute <= 45) or (half is settings.SECOND_HALF and 45 <= minute <= 90))
        return false
    return true

# Returns a copy of the events in unformattedMatch that happen in the time up to and including minute
getEventsFromHalf = (unformattedMatch, minute, half, settings) ->
    eventIndex = 0

    if half is settings.FIRST_HALF
        this_half_events = unformattedMatch[settings.first_half]
    else if half is settings.SECOND_HALF
        this_half_events = unformattedMatch[settings.second_half]
    else
        throw new Error("#{half} is not a valid half")

    eventIndex += 1 while eventIndex < this_half_events.length and minute >= this_half_events[eventIndex].time

    return this_half_events.slice(0,eventIndex)
