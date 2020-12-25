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
  def getAccountId(name)
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

  def getSummonerId(name)
    request = "/lol/summoner/v4/summoners/by-name/#{name}"
    uri = URI("#{self.routing_value+request}?api_key=#{$API_KEY}")
    json = Net::HTTP.get(uri)
    response = JSON.parse(json)

    summonerId = response["id"]
  end

  def getMatchInProgress(name)
    summonerId = self.getSummonerId(name)
    request = "/lol/spectator/v4/active-games/by-summoner/#{summonerId}"
    uri = URI("#{self.routing_value+request}?api_key=#{$API_KEY}")
    httpResponse = Net::HTTP.get_response(uri)
    case httpResponse
    when Net::HTTPNotFound
      return "no game in progress"
    when Net::HTTPSuccess
      json = httpResponse.body
      response = JSON.parse(json)
      gameIdInProgress = response["gameId"]
      gameModeInProgress = response["gameMode"]
      "#{gameIdInProgress} - #{gameModeInProgress}"
    end
  end

  def getLatestVersion
    request = "https://ddragon.leagueoflegends.com/api/versions.json"
    uri = URI(request)
    version = JSON.parse(Net::HTTP.get(uri))[0]
  end

  def parseChampIdJson(fileName)
    if !File.exist?(fileName)
      champIdsFile = File.new(fileName,"w")
      version = self.getLatestVersion
      request = "https://ddragon.leagueoflegends.com/cdn/#{version}/data/en_US/champion.json"
      uri = URI(request)
      json = Net::HTTP.get(uri)
      response = JSON.parse(json)["data"]

      champIdHash = Hash.new
      response.each do |c|
        champIdHash[c[0]] = c[1]["key"]
      end
      champIdsFile.write(champIdHash.to_json)
      champIdHash
    else
      json = File.read(fileName)
      champIdHash = JSON.parse(json)
    end
  end

  def getChampId(name)
    champIdHash = parseChampIdJson("champIds.json")
    champIdHash[name]
  end

  def getChampName(id)
    champIdHash = parseChampIdJson("champIds.json")
    champIdHash.key(id)
  end

  def getMasteryByChamp(summonerId, champId)
    request = "/lol/champion-mastery/v4/champion-masteries/by-summoner/#{summonerId}/by-champion/#{champId}"
    uri = URI("#{self.routing_value+request}?api_key=#{$API_KEY}")
    json = Net::HTTP.get(uri)
    response = JSON.parse(json)

    response["championLevel"]
  end

  def getTopMasteries(summonerId)
    request = "/lol/champion-mastery/v4/champion-masteries/by-summoner/#{summonerId}"
    uri = URI("#{self.routing_value+request}?api_key=#{$API_KEY}")
    json = Net::HTTP.get(uri)
    response = JSON.parse(json).slice(0..2)

    leaderboard = Hash.new
    response.each do |m|
      champName = self.getChampName(m["championId"].to_s)
      mastery = m["championLevel"]
      leaderboard[champName] = mastery
    end
    leaderboard
  end

end
