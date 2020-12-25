require_relative 'riot-api'

api = RiotAPI.new
summoner_name = 'levin'
escaped_name = CGI.escape(summoner_name)
puts "#{escaped_name}"

# ex1, fetching summoner data
accountId = api.getAccountID(escaped_name)
puts "accountId: #{accountId}"

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
