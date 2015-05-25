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
require "cinch"
Dir["./plugins/*.rb"].each { |f| require f }


# Implementation of a reply method that circumvents the limitations of Twitch
# IRC. Reference: https://github.com/cinchrb/cinch/issues/151
#-------------------------------------------------------------------------------
class Cinch::Message
  def twitch(string)
    string = string.to_s.gsub("<","&lt;").gsub(">","&gt;")
    bot.irc.send ":#{bot.config.user}!#{bot.config.user}" +
                 "@#{bot.config.user}.tmi.twitch.tv PRIVMSG " +
                 "#{channel} :#{string}"
  end
end


# Bot implementation
#-------------------------------------------------------------------------------
bot = Cinch::Bot.new do

  # Config
  #-----------------------------------------------------------------------------
  configure do |c|

    # Twitch
    c.server              = "irc.twitch.tv"
    c.port                = 6667
    c.messages_per_second = 0.6   # 20 messages per 30 seconds
    c.ping_interval       = 300   # Twitch ping is every 5 minutes
    c.timeouts.read       = 301   # Something greater than ping interval

    # Login
    c.user     = "misobot"
    c.nick     = "misobot"
    c.channels = ["#tohfoo_"]
    c.password = "oauth:nzrce36n4bgjathx9g8zq2ojsjb0e0"

    # Plugins
    c.plugins.plugins = [Giveaway]
  end
end


# Start the bot
#-------------------------------------------------------------------------------
bot.start
