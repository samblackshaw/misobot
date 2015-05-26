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

# Gems
require "cinch"
require "active_record"
require "yaml"
require "erb"
require "pg"
require "dotenv"; Dotenv.load

# Project files
$LOAD_PATH << "."
Dir["app/models/*.rb"].each  { |f| require f }   # Models
Dir["app/plugins/*.rb"].each { |f| require f }   # Plugins

# Database connection
db_config = YAML::load(ERB.new(File.read("app/config/database.yml")).result)
ActiveRecord::Base.establish_connection(db_config["production"])


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


# Helper class
#-------------------------------------------------------------------------------
class MisoHelper
  @@moderators = [ENV["TWITCH_USER"]]

  def self.mods
    @@moderators
  end

  def self.add_mods(mods)
    @@moderators += mods
  end

  def self.is_mod?(name)
    @@moderators.include? name
  end
end


# Bot implementation
#-------------------------------------------------------------------------------
bot = Cinch::Bot.new do

  configure do |c|

    # Twitch
    c.server              = "irc.twitch.tv"
    c.port                = 6667
    c.messages_per_second = 0.6   # < 20 messages per 30 seconds
    c.ping_interval       = 300   # Twitch ping is every 5 minutes
    c.timeouts.read       = 301   # Something greater than ping interval

    # Login
    c.user     = ENV["TWITCH_BOT_USER"]
    c.nick     = ENV["TWITCH_BOT_USER"]
    c.channels = ["##{ENV['TWITCH_USER']}"]
    c.password = ENV["TWITCH_OAUTH_TOKEN"]

    # Plugins
    c.plugins.plugins = [Giveaways, Tokens, Tokens::Penalty]
  end

  on :connect do |m|
    m.twitch "/mods"
  end

  on :private do |m|
    if m.user.nick == "jtv" && m.params[-1].include?("The moderators")
      MisoHelper.add_mods m.params[-1].split(": ")[-1].split(", ")
    end
  end
end


# Start the bot
#-------------------------------------------------------------------------------
bot.start
