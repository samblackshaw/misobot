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

# Modules
mongoose = require "mongoose"
irc      = require "irc"

# Models
User = require "./models/user"


# Establish Database Connection
#-------------------------------------------------------------------------------
mongoose.connect process.env.MONGOLAB_URI


# Session Variables
#-------------------------------------------------------------------------------
startTime     = Date.now()
queue         = []
queueOpen     = false
queueCurrUser = ""
activeUsers   = {}


# Initialize Misobot
#-------------------------------------------------------------------------------
client = new irc.Client "irc.twitch.tv", process.env.TWITCH_BOT_USER,
  userName: process.env.TWITCH_BOT_USER
  password: process.env.TWITCH_OAUTH_TOKEN
  channels: ["##{process.env.TWITCH_USER}"]

# Helper method to send a message to the user channel.
# @param {message:string}
# @return {void}
client.speak = (message) ->
  this.say "##{process.env.TWITCH_USER}", "/me #{message}"

# Helper method to send a raw message to the user channel.
# @param {message:string}
# @return {void}
client.speakRaw = (message) ->
  this.say "##{process.env.TWITCH_USER}", "#{message}"

# Handle errors to prevent the bot from crashing.
client.addListener "error", (message) -> console.log "[ERROR] #{message}"

# Initialize 15 minute intervals for updating token counts.
setInterval () ->
  timeNow = Date.now()

  # Iterate through every active user
  for name, time of activeUsers
    seconds = Math.floor(Math.abs(timeNow - time) / 1000)
    minutes = Math.floor(seconds / 60)

    # If the user has said something within the past 5 minutes, add tokens
    if minutes <= 5
      User.findOrCreate { name: name }, (err, user) ->
        user.tokens ?= 0
        user.tokens += 10
        user.save()

    # Otherwise, remove that user from the active users list
    else delete activeUsers[name]
, 900000


# Helper Methods
#-------------------------------------------------------------------------------
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

# Looks through an array of objects for a particular key value and returns the
# index of the first instance of a match. Otherwise, return -1.
# @param {array:array}
# @param {key:string}
# @param {value:string}
# @return {number}
indexOfKeyValue = (array, key, value) ->
  index = -1
  array.forEach (obj, _index) -> index = _index if obj[key] == value
  index

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
#-------------------------------------------------------------------------------
client.addListener "message", (from, to, message) ->
  from = formatUser from
  to   = formatUser to

  # Update user's timestamp in active users list.
  activeUsers[from] = Date.now()

  # Display bot commands.
  if /^!commands$/.test message
    client.speak "I can tell you my !uptime, #{process.env.TWITCH_USER}'s !nnid,
      the channel's !discord server link, the stream !playlist, !social outlets,
      and !hug you. If a list is open, you can !join with your NNID or a custom
      message, see your !spot, or !leave if you can't play anymore. You can also
      see how many stream munnies you have with !mytohkens -- those are all my
      commands for now!"

  # Display difference between when this command is executed and the
  # start time in memory.
  else if /^!uptime$/.test message
    client.speak "I've been online for
      #{timeDiff startTime, Date.now()}"

  # Display the streamer's NNID.
  else if /^!nnid$/.test message
    client.speak "NNID: #{process.env.NNID}"

  # Display a link to the stream Discord server.
  else if /^!discord$/.test message
    client.speak "Discord: #{process.env.DISCORD_URL}"

  # Display a link to the stream playlist.
  else if /^!playlist$/.test message
    client.speak "Playlist: #{process.env.PLAYLIST_URL}"

  # Display social media outlets for the stream.
  else if /^!social$/.test message
    client.speak "Keep up with #{process.env.TWITCH_USER} when we're not
      live at #{process.env.TWITTER_URL} and watch videos over at
      #{process.env.YOUTUBE_URL}!"

  # Display a message encouraging users to check out another channel.
  else if /^!shoutout \S*$/.test message
    if isMod from
      params = getParams message
      if params.length == 1
        user = formatUser params[0]
        client.speak "Show #{user} some #{process.env.FOLLOWER_NAME} lovin'
          over at http://twitch.tv/#{user}! <3"

  # Let Misobot hug back users.
  else if /^!hug$/.test message
    client.speak "hugs #{from} <4"

  # Let someone purge their own messages.
  else if /^!seppuku$/.test message
    client.speakRaw "/timeout #{from} 1"

  else if /^!pls \S*$/.test message
    if isMod from
      params = getParams message
      if params.length == 1
        user = formatUser params[0]
        client.speakRaw "/timeout #{user} 1"

  # Open the list.
  else if /^!openlist$/.test message
    if isStreamer from
      queueOpen = true
      client.speak "List is open, type !join {nnid} or !submit {code} to join"

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

  # Restore a list if Miso dies.
  else if /^!restorelist .*$/.test message
    if isStreamer from
      if queue.length == 0
        users = getParams(message)
        users.forEach (user, i) ->
          queue.push { name: user, message: "r e s t o r e d" }
        client.speak "The list has been r e s t o r e d"

  # Display the list.
  else if /^!list$/.test message
    if queue.length > 0
      readableList = queue.map (currentValue, index, array) -> currentValue.name
      client.speak "Current list is: #{readableList.join ', '}"
    else
      client.speak "List is empty :("

  # Move the list along.
  else if /^!next$/.test message
    if isStreamer from
      queueCurrUser = queue.shift()
      if queueCurrUser != undefined
        client.speak "#{queueCurrUser.name}, you're now up! Join message:
          #{queueCurrUser.message}"

        # Tell the next person in line to be ready.
        if queue.length > 0
          client.speak "#{queue[0].name}, you will be up next, please be ready"

      else
        client.speak "We're at the end of the list ShadyLulu"

  # Warning message for join without a message.
  else if /^!join$/.test message
    client.speak "Type !join {nnid} to join the list"

  # Add a user to the list, if it's open.
  else if /^!join .*$|^!submit .*$/.test message
    if queueOpen
      joinMsg = getParams(message).join " "
      if joinMsg.length > 0
        # Make it a requirement for the parameter to be less than 140 chars.
        if joinMsg.length <= 140
          if indexOfKeyValue(queue, "name", from) == -1
            queue.push { name: from, message: joinMsg }
            client.speak "#{from}, you've been added to the list! You are
              ##{queue.length} in the list"
          else
            client.speak "#{from} I already have you in the list, be patient pls"
        else
          client.speak "#{from}, please make your join message less than 140
            characters"
    else
      client.speak "Sorry, the list isn't open right now"

  # Move user from list.
  else if /^!move .*$/.test message
    if isMod from
      params = getParams(message)
      if params.length == 2
        user = params[0]
        pos  = params[1]

        if !isNaN(pos)
          pos       = parseInt pos
          pos       = Math.max Math.min(pos, queue.length), 1
          userIndex = indexOfKeyValue(queue, "name", user)

          if userIndex > -1
            _user = queue.splice userIndex, 1
            queue.splice pos-1, 0, _user[0]
            client.speak "#{user} was moved from list position ##{userIndex+1} to
              ##{pos}"
          else
            client.speak "#{user} is not currently in the list"

        else
          client.speak "#{from}, make sure you provide a whole number"

      else
        client.speak "#{from}, make sure you provide a user and list position"

  # Remove users from the list.
  else if /^!remove .*$/.test message
    if isMod from
      users = getParams(message)
      users.forEach (user, i) ->
        userIndex = indexOfKeyValue(queue, "name", user)
        if userIndex > -1
          queue.splice userIndex, 1
          client.speak "#{user} was removed from the list"
        else
          client.speak "#{user} is not in the list"

  # Say what place in line someone is.
  else if /^!spot$/.test message
    userIndex = indexOfKeyValue(queue, "name", from)
    if userIndex == 0
      client.speak "#{from}, you're next in the list! Please be ready"
    else if userIndex > -1
      client.speak "#{from}, you're ##{userIndex + 1} in the list"
    else
      client.speak "You're not in the list"

  # Remove a user from the list.
  else if /^!leave$/.test message
    userIndex = indexOfKeyValue(queue, "name", from)
    if userIndex > -1
      queue.splice userIndex, 1
      client.speak "Okay #{from}, I've removed you from the list"
    else
      client.speak "#{from}, I don't have you in the list so you're all good"

  # Display user's token balance.
  else if /^!mytohkens$/.test message
    User.findOrCreate { name: from }, (err, user) ->
      client.speak "#{from}, you currently have #{user.tokens}
        #{process.env.TOKENS_NAME} -- roughly #{user.tokens/10*15} minutes
        worth of active chit chat :3"
