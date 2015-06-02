exports.dataAtTime = (unformattedData, minute, half, dfConfig) ->
    throw new Error("ERROR: #{minute} in #{half} is not a valid time combination") if not isTimeValid(minute, half, dfConfig)

    try
        outputData = {}
        outputData[dfConfig.matches] = []

        for match in unformattedData.matches
            outputMatch = createMatchObject(match, minute, half, dfConfig)
            outputData[dfConfig.matches].push(outputMatch)

        outputData[dfConfig.error] = dfConfig.NO_ERROR
    catch error
        outputData[dfConfig.error] = error
    finally
        outputData[dfConfig.server] = dfConfig.FOOTBALL_API_MOCK
        return outputData

# Creates a match object from the unformatted (imported from YAML) state
# according to the provided minute and half
createMatchObject = (unformattedMatch, minute, half, dfConfig) ->
    outputMatch = {}
    outputEvents = []

    goals = {}
    goals[dfConfig.HOME_TEAM] = 0
    goals[dfConfig.AWAY_TEAM] = 0

    outputMatch[dfConfig.home_team] = unformattedMatch.home_team
    outputMatch[dfConfig.away_team] = unformattedMatch.away_team

    first_half_events = getEventsFromHalf(unformattedMatch, minute, dfConfig.FIRST_HALF, dfConfig)
    outputEvents.push(formatEvent(unformattedEvent, unformattedMatch, goals, dfConfig)) for unformattedEvent in first_half_events
    outputMatch[dfConfig.ht_score] = if minute >= 45 then "[#{goals[dfConfig.HOME_TEAM]}-#{goals[dfConfig.AWAY_TEAM]}]" else dfConfig.SCORE_NOT_REACHED

    if half is dfConfig.SECOND_HALF
        second_half_events = getEventsFromHalf(unformattedMatch, minute, dfConfig.SECOND_HALF, dfConfig)
        outputEvents.push(formatEvent(unformattedEvent, unformattedMatch, goals, dfConfig)) for unformattedEvent in second_half_events
    outputMatch[dfConfig.ft_score] = if minute >= 90 then "[#{goals[dfConfig.HOME_TEAM]}-#{goals[dfConfig.AWAY_TEAM]}]" else dfConfig.SCORE_NOT_REACHED

    outputMatch[dfConfig.match_time] = if minute < 90 then "#{minute}" else dfConfig.MATCH_FINISHED
    outputMatch[dfConfig.match_home_team_score] = "#{goals[dfConfig.HOME_TEAM]}"
    outputMatch[dfConfig.match_away_team_score] = "#{goals[dfConfig.AWAY_TEAM]}"

    isHalfTime = half is dfConfig.FIRST_HALF and minute >= 45
    isFullTime = half is dfConfig.SECOND_HALF and minute >= 90
    outputMatch[dfConfig.match_status] = if isHalfTime then dfConfig.HALF_TIME else if isFullTime then dfConfig.FULL_TIME else "#{minute}"

    outputMatch[dfConfig.events] = outputEvents

    return outputMatch

# Formats an event (goal, yellow card etc) from an object from the unformatted (imported from YAML) state
# and updates the goals object accordingly
formatEvent = (unformattedEvent, unformattedMatch, goals, dfConfig) ->
    formattedEvent = {}

    formattedEvent[dfConfig.type] = unformattedEvent.type
    formattedEvent[dfConfig.time] = '' + unformattedEvent.time
    formattedEvent[dfConfig.player] = unformattedEvent.player
    formattedEvent[dfConfig.team] = if unformattedEvent.team is unformattedMatch.home_team then dfConfig.HOME_TEAM else dfConfig.AWAY_TEAM

    if unformattedEvent.type is dfConfig.GOAL
        goals[formattedEvent[dfConfig.team]] += 1
        formattedEvent[dfConfig.event_result] = "[#{goals[dfConfig.HOME_TEAM]} - #{goals[dfConfig.AWAY_TEAM]}]"
    else
        formattedEvent[dfConfig.event_result] = dfConfig.NO_EFFECT_ON_SCORE

    return formattedEvent


# Returns whether minute is a valid minute in half
# where the first half can be 0-45mins (inclusive), and the second half can be 45-90mins (inclusive)
isTimeValid = (minute, half, dfConfig) ->
    if not ((half is dfConfig.FIRST_HALF and 0 <= minute <= 45) or (half is dfConfig.SECOND_HALF and 45 <= minute <= 90))
        return false
    return true

# Returns a copy of the events in unformattedMatch that happen in the time up to and including minute
getEventsFromHalf = (unformattedMatch, minute, half, dfConfig) ->
    eventIndex = 0

    if half is dfConfig.FIRST_HALF
        this_half_events = unformattedMatch[dfConfig.first_half]
    else if half is dfConfig.SECOND_HALF
        this_half_events = unformattedMatch[dfConfig.second_half]
    else
        throw new Error("ERROR: #{half} is not a valid half")

    eventIndex += 1 while eventIndex < this_half_events.length and minute >= this_half_events[eventIndex].time

    return this_half_events.slice(0,eventIndex)