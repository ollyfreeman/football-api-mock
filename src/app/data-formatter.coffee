# Format an object with matches data which is an unformatted (imported from YAML) state
# Uses a config file which provides a mapping from unformatted to formatted keys and values
exports.format = (unformattedData, config) ->
    try
        formattedData = {}
        matches = []
        for unformattedMatch in unformattedData[config.matches.unformatted]
            formattedMatch = formatMatch(unformattedMatch, config)
            matches.push(formattedMatch)
        formattedData[config.matches.formatted] = matches
        return formattedData
    catch error
        throw new Error('Error while formatting data object')

# Formats a match from an object from the unformatted (imported from YAML) state
formatMatch = (unformattedMatch, config) ->
    formattedMatch = {}
    formattedMatch[config.match_home_team.formatted] = unformattedMatch[config.match_home_team.unformatted]
    formattedMatch[config.match_away_team.formatted] = unformattedMatch[config.match_away_team.unformatted]

    goals = {}
    goals[config.home_team.formatted] = 0
    goals[config.away_team.formatted] = 0

    formattedEvents_firstHalf = []
    for unformattedEvent in unformattedMatch[config.first_half.unformatted]
        formattedEvent = formatEvent(unformattedEvent, unformattedMatch, goals, config)
        formattedEvents_firstHalf.push(formattedEvent)
    formattedMatch[config.first_half.formatted] = formattedEvents_firstHalf

    formattedEvents_secondHalf  = []
    for unformattedEvent in unformattedMatch[config.second_half.unformatted]
        formattedEvent = formatEvent(unformattedEvent, unformattedMatch, goals, config)
        formattedEvents_secondHalf.push(formattedEvent)
    formattedMatch[config.second_half.formatted] = formattedEvents_secondHalf

    return formattedMatch

# Formats an event (goal, yellow card etc) from an object from the unformatted (imported from YAML) state
formatEvent = (unformattedEvent, unformattedMatch, goals, config) ->
    formattedEvent = {}

    formattedEvent[config.event_minute.formatted] = '' + unformattedEvent[config.event_minute.unformatted]
    formattedEvent[config.event_type.formatted] = unformattedEvent[config.event_type.unformatted]
    formattedEvent[config.event_player.formatted] = unformattedEvent[config.event_player.unformatted]

    if unformattedEvent[config.event_team.unformatted] == unformattedMatch[config.match_home_team.unformatted]
        formattedEvent[config.event_team.formatted] = config.home_team.formatted
    else
        formattedEvent[config.event_team.formatted] = config.away_team.formatted

    if unformattedEvent[config.event_type.unformatted] == config.goal.unformatted
        goals[formattedEvent[config.event_team.formatted]] += 1
        formattedEvent[config.event_result.formatted] = "[#{goals.localteam} - #{goals.visitorteam}]"
    else
        formattedEvent[config.event_result.formatted] = ''

    return formattedEvent
