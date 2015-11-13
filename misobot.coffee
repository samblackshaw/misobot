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
irc = require "irc"
_   = require "underscore"
require("dotenv").load()


# MisoSTM (Short Term Memory)
#-------------------------------------------------------------------------------
MisoSTM =
  startTime: Date.now()


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
  this.say "##{process.env.TWITCH_USER}", message

# Handle errors to prevent the bot from crashing.
# @param {message:string}
# @return {void}
client.addListener "error", (message) ->
  console.log "[ERROR] #{message}"


# Commands
#-------------------------------------------------------------------------------
client.addListener "message", (from, to, message) ->

  # Look for a beginning "!" and trim it
  if message.startsWith "!"
    message = message[1..]
    switch message

      # Display an informative message regarding bot commands.
      when "commands"
        client.speak "To see all my commands, please check the channel bio :)"

      # Display difference between when this command is executed and the
      # start time in memory.
      when "uptime"
        client.speak "Time difference will go here once I figure it out :)"
