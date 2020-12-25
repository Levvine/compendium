require 'dotenv/load'
require 'cgi'
require 'uri'
require 'net/http'
require 'json'

class RiotAPI

  $API_KEY = ENV['API_KEY']

  def initialize
    @routing_value = "https://na1.api.riotgames.com"
  end

  attr_accessor :routing_value

  # gets account id from summoner name
  def getAccountID(name)
    request = "/lol/summoner/v4/summoners/by-name/#{name}"
    uri = URI("#{self.routing_value+request}?api_key=#{$API_KEY}")
    json = Net::HTTP.get(uri)
    response = JSON.parse(json)

    accountId = response["accountId"]
  end

  def getLastMatchId(accountId)
    request = "/lol/match/v4/matchlists/by-account/#{accountId}"
    uri = URI("#{self.routing_value+request}?api_key=#{$API_KEY}")
    json = Net::HTTP.get(uri)
    response = JSON.parse(json)

    matchId = response["matches"][0]["gameId"]
  end

  def getTeamParticipants(matchId)
    request = "/lol/match/v4/matches/#{matchId}"
    uri = URI("#{self.routing_value+request}?api_key=#{$API_KEY}")
    json = Net::HTTP.get(uri)
    response = JSON.parse(json)
    
    participants = response["participantIdentities"].map do |p|
      p["player"]["summonerName"]
    end
  end

end
