#-------------------------------------------------------------------------------
# twitch_helper.rb
#
# Altered implementation of a reply method that circumvents the limitations of
# Twitch IRC. Reference: https://github.com/cinchrb/cinch/issues/151
#-------------------------------------------------------------------------------
class Cinch::Message
  def twitch(string)
    string = string.to_s.gsub("<","&lt;").gsub(">","&gt;")
    bot.irc.send ":#{bot.config.user}!#{bot.config.user}" +
                 "@#{bot.config.user}.tmi.twitch.tv PRIVMSG " +
                 "##{ENV['TWITCH_USER']} :#{string}"
  end
end
