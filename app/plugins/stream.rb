#===============================================================================
# stream.rb
#
# Implements general stream commands.
#
# Dependencies:
# - MisoSTM
# - ActiveSupport
# - ActiveRecord
#===============================================================================

class Stream
end

# Display social media outlets for stream.
# @command !social
class Stream::Social
  include Cinch::Plugin
  include MisoHelper
  match "social"

  def execute(m)
    if MisoSTM.is_mod? m.user.nick
      m.twitch_colored "Keep up with #{ENV['TWITCH_USER']} when we're not " +
        "live at #{ENV['TWITTER_URL']} and watch highlights and videos over " +
        "at #{ENV['YOUTUBE_URL']}!"
    else
      m.twitch_colored "SwiftRage Sorry, only mods can use this command"
    end
  end
end
