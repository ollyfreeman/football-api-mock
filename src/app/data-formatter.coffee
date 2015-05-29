exports.format = (unformattedObject, config) ->
    formattedObject = {}
    matches = []
    for unformattedMatch in unformattedObject[config.matches.unformatted]
        formattedMatch = formatMatch(unformattedMatch, config)
        matches.push(formattedMatch)
    formattedObject[config.matches.formatted] = matches
    return formattedObject

formatMatch = (unformattedMatch, config) ->
    formattedMatch = {}
    formattedMatch[config.match_home_team.formatted] = unformattedMatch[config.match_home_team.unformatted]
    formattedMatch[config.match_away_team.formatted] = unformattedMatch[config.match_away_team.unformatted]

    goals = {}
    goals.localteam = 0
    goals.visitorteam = 0

    formattedEvents_firstHalf = []
    formattedEvents_secondHalf  = []
    for unformattedEvent in unformattedMatch[config.first_half.unformatted]
        formattedEvent = formatEvent(unformattedEvent, unformattedMatch, goals, config)
        formattedEvents_firstHalf.push(formattedEvent)
    formattedMatch[config.match_ht_score.formatted] = "[#{goals.localteam}-#{goals.visitorteam}]"
    for unformattedEvent in unformattedMatch[config.second_half.unformatted]
        formattedEvent = formatEvent(unformattedEvent, unformattedMatch, goals, config)
        formattedEvents_secondHalf.push(formattedEvent)
    formattedMatch[config.match_ft_score.formatted] = "[#{goals.localteam}-#{goals.visitorteam}]"
    formattedMatch[config.first_half.formatted] = formattedEvents_firstHalf
    formattedMatch[config.second_half.formatted] = formattedEvents_secondHalf

    return formattedMatch

formatEvent = (unformattedEvent, unformattedMatch, goals, config) ->
    formattedEvent = {}
    formattedEvent[config.event_minute.formatted] = '' + unformattedEvent[config.event_minute.unformatted]
    if unformattedEvent[config.event_team.unformatted] == unformattedMatch[config.match_home_team.unformatted]
        formattedEvent[config.event_team.formatted] = config.home_team.formatted
    else
        formattedEvent[config.event_team.formatted] = config.away_team.formatted
    formattedEvent[config.event_player.formatted] = unformattedEvent[config.event_player.unformatted]

    formattedEvent[config.event_type.formatted] = unformattedEvent[config.event_type.unformatted]
    if unformattedEvent[config.event_type.unformatted] == config.goal.unformatted
        goals[formattedEvent[config.event_team.formatted]] += 1
        formattedEvent[config.event_result.formatted] = "[#{goals.localteam} - #{goals.visitorteam}]"
    else
        formattedEvent[config.event_result.formatted] = ''

    return formattedEvent
