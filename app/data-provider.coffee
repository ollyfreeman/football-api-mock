fileLoader = require('./file-loader')

# Returns an object that represents the match status at minute in half.
# The object conforms to the football-api.com API
exports.dataAtTime = (app, minute, half) ->
    settings = app.settings

    try
        outputData = {}

        outputData[settings.matches] = []
        unformattedData = settings.data

        for match in unformattedData.matches
            outputMatch = createMatchObject(match, minute, half, settings)
            outputData[settings.matches].push(outputMatch)

        outputData[settings.error] = settings.NO_ERROR
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

    outputEvents.push(getFormattedEvents(unformattedMatch, minute, settings.FIRST_HALF, goals, settings)...)
    outputMatch[settings.ht_score] = getHtScore(minute, goals, settings)

    if half is settings.SECOND_HALF
        outputEvents.push(getFormattedEvents(unformattedMatch, minute, settings.SECOND_HALF, goals, settings)...)
    outputMatch[settings.ft_score] = getFtScore(minute, goals, settings)

    outputMatch[settings.events] = outputEvents

    outputMatch[settings.match_time] = getMatchTime(minute, settings)
    outputMatch[settings.match_home_team_score] = getHomeTeamScore(goals, settings)
    outputMatch[settings.match_away_team_score] = getAwayTeamScore(goals, settings)

    outputMatch[settings.match_status] = getMatchStatus(minute, half, settings)

    return outputMatch

# Returns a list of formatted events, created from unformatted events, according to the values
# of minute, half and goals
getFormattedEvents = (unformattedMatch, minute, half, goals, settings) ->
    unformattedEvents = getEventsFromHalf(unformattedMatch, minute, half, settings)
    formattedEvents = []
    for unformattedEvent in unformattedEvents
        formattedEvent = formatEvent(unformattedEvent, unformattedMatch, goals, settings)
        formattedEvents.push(formattedEvent)
    return formattedEvents

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

# Formats an event (goal, yellow card etc) from an object from the unformatted (imported from YAML) state
# and updates the goals object accordingly
formatEvent = (unformattedEvent, unformattedMatch, goals, settings) ->
    formattedEvent = {}

    formattedEvent[settings.type] = unformattedEvent.type
    formattedEvent[settings.time] = '' + unformattedEvent.time
    formattedEvent[settings.player] = unformattedEvent.player
    formattedEvent[settings.team] = getEventTeam(unformattedEvent, unformattedMatch, settings)

    if unformattedEvent.type is settings.GOAL
        goals[formattedEvent[settings.team]] += 1
        formattedEvent[settings.event_result] = getEventResult(goals, settings)
    else
        formattedEvent[settings.event_result] = settings.NO_EFFECT_ON_SCORE

    return formattedEvent

# Returns the value of the 'Match HT Score' property
getHtScore = (minute, goals, settings) ->
    if minute >= 45
        "[#{goals[settings.HOME_TEAM]}-#{goals[settings.AWAY_TEAM]}]"
    else
        settings.SCORE_NOT_REACHED

# Returns the value of the 'Match FT Score' property
getFtScore = (minute, goals, settings) ->
    if minute >= 90
        "[#{goals[settings.HOME_TEAM]}-#{goals[settings.AWAY_TEAM]}]"
    else
        settings.SCORE_NOT_REACHED

# Returns the number of goals scored by the home team
getHomeTeamScore = (goals, settings) ->
    "#{goals[settings.HOME_TEAM]}"

# Returns the number of goals scored by the away team
getAwayTeamScore = (goals, settings) ->
    "#{goals[settings.AWAY_TEAM]}"

# Returns the status of the game
getMatchStatus = (minute, half, settings) ->
    isHalfTime = half is settings.FIRST_HALF and minute >= 45
    isFullTime = half is settings.SECOND_HALF and minute >= 90
    if isHalfTime then settings.HALF_TIME else if isFullTime then settings.FULL_TIME else "#{minute}"

# Returns the match time
getMatchTime = (minute, settings) ->
    if minute < 90 then "#{minute}" else settings.MATCH_FINISHED

# Returns the team of the player involved in the given event
getEventTeam = (unformattedEvent, unformattedMatch, settings) ->
    if unformattedEvent.team is unformattedMatch.home_team then settings.HOME_TEAM else settings.AWAY_TEAM

# Returns the score
getEventResult = (goals, settings) ->
    "[#{goals[settings.HOME_TEAM]} - #{goals[settings.AWAY_TEAM]}]"
