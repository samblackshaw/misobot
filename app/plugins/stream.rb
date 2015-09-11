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

# Prompt display of available commands.
# @command !commands
class Stream::Commands
  include Cinch::Plugin
  include MisoHelper
  match "commands"

  def execute(m)
    m.twitch_colored "To see available commands, please check the channel " +
      "description :)"
  end
end

# Display the uptime since Misobot has been started.
# @command !uptime
class Stream::Uptime
  include Cinch::Plugin
  include MisoHelper
  match "uptime"

  def execute(m)
    m.twitch_colored "Uptime: #{time_diff(MisoSTM::START_TIME, Time.now)}"
  end
end

# Display social media outlets for stream.
# @command !social
class Stream::Social
  include Cinch::Plugin
  include MisoHelper
  match "social"

  def execute(m)
    m.twitch_colored "Keep up with #{ENV['TWITCH_USER']} when we're not " +
      "live at #{ENV['TWITTER_URL']} and watch highlights and videos over " +
      "at #{ENV['YOUTUBE_URL']}!"
  end
end

# Shoutout another streamer.
# @command !shoutout {username}
class Stream::Shoutout
  include Cinch::Plugin
  include MisoHelper
  match /shoutout.*/

  def execute(m)
    if MisoSTM.is_mod? m.user.nick
      params = extract_params(m)
      if params.count == 1
        username = format_username(params.first)
        m.twitch_colored "Show a fellow streamer @#{username} some " +
          "#{ENV['FOLLOWER_NAME']} lovin' over at " +
          "http://twitch.tv/#{username}! <3"
      end
    else
      m.twitch_colored "SwiftRage Sorry, only mods can use this command"
    end
  end
end
