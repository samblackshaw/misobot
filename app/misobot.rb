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
require "active_support/core_ext"
require "yaml"
require "erb"
require "pg"
require "dotenv"; Dotenv.load

# Project files
$LOAD_PATH << "."
Dir["app/models/*.rb"].each   { |f| require f }   # Models
Dir["app/helpers/*.rb"].each  { |f| require f }   # Helpers
Dir["app/plugins/*.rb"].each  { |f| require f }   # Plugins

# Database connection
db_config = YAML::load(ERB.new(File.read("app/config/database.yml")).result)
ActiveRecord::Base.establish_connection(db_config["production"])


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
    c.plugins.plugins = [
      Tokens::MyTokens, Tokens::PenalizeTokens,
      Queues::Open, Queues::Close, Queues::Clear, Queues::Line, Queues::Next,
      Queues::Join, Queues::Unjoin, Queues::Spot
    ]
  end

  # Request moderator list upon successful connect
  on :connect do |m|
    m.twitch "/mods"

    Tokens.init_loyalty_system if Tokens
  end

  # Update moderator list upon receiving list of moderators
  on :private do |m|
    if m.user.nick == "jtv" && m.params[-1].include?("The moderators")
      MisoSTM.add_mods m.params[-1].split(": ")[-1].split(", ")
    end
  end

  # Update active user timestamp upon receiving a message
  on :message do |m|
    MisoSTM.update_active_user(m.user.nick)
  end
end

# Start the bot
bot.start
