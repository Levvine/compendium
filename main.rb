require_relative 'riot-api'

api = RiotAPI.new
summoner_name = 'lIlIIllIlII'
escaped_name = CGI.escape(summoner_name)
puts "#{escaped_name}"

# ex1, fetching summoner data
accountId = api.getAccountId(escaped_name)
summonerId = api.getSummonerId(escaped_name)
puts "accountId: #{accountId}"
puts "summonerId: #{summonerId}"


# ex2, fetch match history
matchId = api.getLastMatchId(accountId)
puts "matchId: #{matchId}"

# ex3, fetch match data
participants = api.getTeamParticipants(matchId)
team1 = participants.slice(0...4).join(", ")
team2 = participants.slice(5...9).join(", ")
puts "team1: #{team1}"
puts "team2: #{team2}"

# ex4, look up a match-in-progress
matchInProgress = api.getMatchInProgress(escaped_name)
puts "gameId: #{matchInProgress}"

# ex5a, get champion mastery by player id and champion id
# champ_name = "Ashe"
# champId = api.getChampId(champ_name)
# masteryByChamp = api.getMasteryByChamp(summonerId, champId)
# puts "#{champ_name} Mastery Level: #{masteryByChamp}"

# ex5, get top three masteries by points
puts "Top 3 Masteries:"
leaderboard = api.getTopMasteries(summonerId)
leaderboard.each { |m| puts "#{m[0]}: #{m[1]}" }
