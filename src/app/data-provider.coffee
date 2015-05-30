#TODO: need to pull 'first_half' and 'second_half' out into a constant - maybe put the matchData config stuff in the same file but under a matchData property
#TODO: change all the 'formatted'/'unformatted' stuff in the config to '.f' or '.u'

exports.dataAtTime = (formattedData, minute, half, config) ->
    try
        outputData = {}

        if not isTimeValid(minute, half, config) then throw new Error("ERROR: #{minute} in #{half} is not a valid time combination")

        outputData[config.matches.formatted] = []

        for match in formattedData[config.matches.formatted]
            outputMatch = {}
            outputEvents = []

            goals = {}
            goals[config.home_team.formatted] = 0
            goals[config.away_team.formatted] = 0

            outputMatch[config.match_home_team.formatted] = match[config.match_home_team.formatted]
            outputMatch[config.match_away_team.formatted] = match[config.match_away_team.formatted]

            first_half_events = getEventsFromHalf(match, goals, minute, 'first_half', config)
            outputEvents.push(first_half_events...)
            outputMatch[config.match_ht_score.formatted] = if minute >= 45 then "[#{goals[config.home_team.formatted]}-#{goals[config.away_team.formatted]}]" else ''
            if half == 'second_half'
                second_half_events = getEventsFromHalf(match, goals, minute, 'second_half', config)
                outputEvents.push(second_half_events...)
            outputMatch[config.match_ft_score.formatted] = if minute >= 90 then "[#{goals[config.home_team.formatted]}-#{goals[config.away_team.formatted]}]" else ''

            outputMatch[config.match_time.formatted] = if minute < 90 then "#{minute}" else ''
            outputMatch[config.match_home_team_score.formatted] = "#{goals[config.home_team.formatted]}"
            outputMatch[config.match_away_team_score.formatted] = "#{goals[config.away_team.formatted]}"
            if half == 'first_half' and minute >= 45
                outputMatch[config.match_status.formatted] = 'HT'
            else if half == 'second_half' and minute >= 90
                outputMatch[config.match_status.formatted] = 'FT'
            else
                outputMatch[config.match_status.formatted] = "#{minute}"

            outputMatch[config.match_events.formatted] = outputEvents
            outputData[config.matches.formatted].push(outputMatch)

        outputData[config.error.formatted] = 'OK'
        outputData[config.server.formatted] = 'football-api-mock'
        return outputData
    catch error
        outputData[config.error.formatted] = error
        outputData[config.server.formatted] = 'football-api-mock'
        return outputData

isTimeValid = (minute, half, config) ->
    first_half = config.first_half.formatted
    second_half = config.second_half.formatted
    if not ((half == first_half and 0 <= minute <= 45) or (half == second_half and 45 <= minute <= 90))
        return false
    return true

getEventsFromHalf = (match, goals, minute, half, config) ->
    eventIndex = 0
    this_half_events = match[config[half].formatted]
    while eventIndex < this_half_events.length and minute >= this_half_events[eventIndex][config.event_minute.formatted]
        this_half_event = this_half_events[eventIndex]
        if this_half_event[config.event_type.formatted] == config.goal.formatted
            goals[this_half_event[config.event_team.formatted]] += 1
        eventIndex += 1
    return this_half_events.slice(0,eventIndex)
