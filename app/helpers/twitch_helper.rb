#-------------------------------------------------------------------------------
# twitch_helper.rb
#
# Helpers that assist in making calls to the psuedo IRC platform Twitch has.
#-------------------------------------------------------------------------------

# Altered implementation of a reply method that circumvents the limitations of
# Twitch IRC. Reference: https://github.com/cinchrb/cinch/issues/151
# @param {string} - message
#-------------------------------------------------------------------------------
class Cinch::Message
  def twitch(message)
    message = message.to_s.gsub("<","&lt;").gsub(">","&gt;")
    bot.irc.send ":#{bot.config.user}!#{bot.config.user}" +
                 "@#{bot.config.user}.tmi.twitch.tv PRIVMSG " +
                 "##{ENV['TWITCH_USER']} :#{message}"
  end
end
