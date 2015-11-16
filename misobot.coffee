#===============================================================================
#                      __  __ _           _           _
#                     |  \/  (_)___  ___ | |__   ___ | |_
#                     | |\/| | / __|/ _ \| '_ \ / _ \| __|
#                     | |  | | \__ \ (_) | |_) | (_) | |_
#                     |_|  |_|_|___/\___/|_.__/ \___/ \__|
#
#===============================================================================

# Dependencies
#-------------------------------------------------------------------------------
require("dotenv").load()
irc    = require "irc"
mongo  = require("mongodb").MongoClient
assert = require "assert"


# Establish Database Connection
#-------------------------------------------------------------------------------
mongo.connect process.env.MONGOLAB_URI, (err, db) ->
  assert.equal null, err


  # Session Variables
  #-----------------------------------------------------------------------------
  startTime     = Date.now()
  queue         = []
  queueOpen     = false
  queueCurrUser = ""


  # Initialize Misobot
  #-----------------------------------------------------------------------------
  client = new irc.Client "irc.twitch.tv", process.env.TWITCH_BOT_USER,
    userName: process.env.TWITCH_BOT_USER
    password: process.env.TWITCH_OAUTH_TOKEN
    channels: ["##{process.env.TWITCH_USER}"]

  # Helper method to send a message to the user channel.
  # @param {message:string}
  # @return {void}
  client.speak = (message) ->
    this.say "##{process.env.TWITCH_USER}", "/me #{message}"

  # Handle errors to prevent the bot from crashing.
  # @param {message:string}
  # @return {void}
  client.addListener "error", (message) -> console.log "[ERROR] #{message}"


  # Helper Methods
  #-----------------------------------------------------------------------------
  # Determines whether or not a given user is the streamer.
  # @param {user:string}
  # @return {boolean}
  isStreamer = (user) -> user == process.env.TWITCH_USER

  # Determines whether or not a given user is a moderator.
  # @param {user:string}
  # @return {boolean}
  isMod = (user) -> process.env.MODERATORS.indexOf(user) > -1

  # Given a command, extracts all parameters and returns as an array.
  # @param {command:string}
  # @return {array}
  getParams = (command) ->
    params = command.split " "
    if params.length > 1 then params[1..] else params

  # Given a username, formats so that data entry can stay consistent.
  # @param {user:string}
  # @return {string}
  formatUser = (user) -> user.toLowerCase().replace /@/g, ""

  # Pads a number with a leading 0 if the number is a single digit.
  # @param {num:number}
  # @return {string}
  pad = (num) -> if num < 10 then "0#{num}" else num

  # Gives an hours and minutes difference between two Date objects.
  # @param {date1:date}
  # @param {date2:date}
  # @return {string}
  timeDiff = (date1, date2) ->
    seconds  = Math.floor(Math.abs(date1 - date2) / 1000)
    hours    = Math.floor(seconds / 3600)
    seconds -= hours * 3600
    minutes  = Math.floor(seconds / 60)
    seconds -= minutes * 60
    "#{hours}:#{pad minutes}:#{pad seconds}"


  # Commands
  #-----------------------------------------------------------------------------
  client.addListener "message", (from, to, message) ->
    from = formatUser from
    to   = formatUser to

    # Display an informative message regarding bot commands.
    if /^!commands$/.test message
      client.speak "To see all my commands, please check the channel bio :)"

    # Display difference between when this command is executed and the
    # start time in memory.
    else if /^!uptime$/.test message
      client.speak "I've been online for
        #{timeDiff startTime, Date.now()}"

    # Display social media outlets for the stream.
    else if /^!social$/.test message
      client.speak "Keep up with #{process.env.TWITCH_USER} when we're not
        live at #{process.env.TWITTER_URL} and watch videos over at
        #{process.env.YOUTUBE_URL}!"

    # Display a message encouraging users to check out another channel.
    else if /^!shoutout \S*$/.test message
      if isMod from
        params = getParams message
        if params.length > 0
          user = formatUser params[0]
          client.speak "Show #{user} some #{process.env.FOLLOWER_NAME} lovin'
            over at http://twitch.tv/#{user}! <3"

    # Open the list.
    else if /^!openlist$/.test message
      if isStreamer from
        queueOpen = true
        client.speak "List is open, type !join to join"

    # Close the list.
    else if /^!closelist$/.test message
      if isMod from
        queueOpen = false
        client.speak "List is now closed, womp womp CorgiDerp"

    # Clear the list.
    else if /^!clearlist$/.test message
      if isStreamer from
        queue = []
        client.speak "I cleared the list, master <3"

    # Display the list.
    else if /^!list$/.test message
      if queue.length > 0
        client.speak "Current list is: #{queue.join ', '}"
      else
        client.speak "List is empty :("

    # Move the list along.
    else if /^!next$/.test message
      if isStreamer from
        queueCurrUser = queue.shift()
        if queueCurrUser.length > 0
          client.speak "#{queueCurrUser}, you're now up! CoolCat"
        else
          client.speak "We're at the end of the list ShadyLulu"

    # Add a user to the list, if it's open.
    else if /^!join$/.test message
      if queueOpen
        if !queue.indexOf(from) > -1
          queue.push from
          client.speak "#{from}, you've been added to the list! You are
            ##{queue.length} in the list"
        else
          client.speak "#{from} I already have you in the list, be patient pls"
      else
        client.speak "Sorry, the list isn't open right now"

    # Remove a user from the list.
    else if /^!leave$/.test message
      if queue.indexOf(from) > -1
        queue.splice queue.indexOf(from), 1
        client.speak "Okay #{from}, I've removed you from the list"
      else
        client.speak "#{from}, I don't have you in the list so you're all good"
