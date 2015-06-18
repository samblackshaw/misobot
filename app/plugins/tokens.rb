#===============================================================================
# tokens.rb
#
# Implements a stream currency system.
#
# Dependencies:
# - MisoSTM
# - ActiveSupport
# - ActiveRecord
#===============================================================================

# Base Tokens class to store tokens-specific data and methods that can be used
# in all Tokens-related plugins.
class Tokens
  NAME         = ENV["TOKENS_NAME"]
  REFRESH_TIME = 15.minutes
  INCREMENT_BY = 10
  PENALIZE_BY  = 10
  SOFT_PENALTY = 5

  # Create thread that refreshes active users every {REFRESH_TIME} units of
  # time and rewards active users with tokens.
  def self.init_loyalty_system
    Thread.new do
      loop do
        sleep REFRESH_TIME
        MisoSTM.refresh_active_users
        MisoSTM.active_users.each_key do |name|
          user = User.find_or_create_by(name: name)
          user.update_attributes(tokens: user.tokens + INCREMENT_BY)
        end
      end
    end
  end

  # Removes {amount} from {username}'s token value. Value cannot dip below 0.
  # @param {string}  - username
  # @param {integer} - amount
  # @param {message} - m
  def self.remove(username, amount, m)
    username.gsub!("@", "")
    user = User.find_or_create_by(name: username)

    # Deduct amount from number of tokens
    tokens = user.tokens - amount; tokens = 0 if tokens < 0
    user.update_attributes(tokens: tokens)
    m.twitch "SMOrc @#{user.name}, you have been penalized #{amount} " +
             "#{Tokens::NAME}."
  end
end

# Display current number of tokens.
# @command !mytohkens
class Tokens::MyTokens
  include Cinch::Plugin
  match "mytohkens"

  def execute(m)
    user = User.find_or_create_by(name: m.user.nick)
    m.twitch "@#{user.name}, you have #{user.tokens} #{Tokens::NAME}."
  end
end

# Give tokens to another user.
# @command !givetohkens {username} {amount}
class Tokens::GiveTokens
  include Cinch::Plugin
  match /givetohkens.*/

  def execute(m)
    username = m.user.nick.gsub("@", "")
    user     = User.find_or_create_by(name: username)
  end
end

# Penalize tokens from a user. Only mods are able to use this command.
# @command !penalizetohkens {username}
class Tokens::PenalizeTokens
  include Cinch::Plugin
  match /penalizetohkens.*/

  def execute(m)
    if MisoSTM.is_mod? m.user.nick
      params = m.params[-1].split(" ")
      Tokens.remove(params[1], PENALIZE_BY, m) if params.count == 2
    else
      m.twitch "SwiftRage @#{m.user.nick}, you ain't no mod!"
      Tokens.remove(m.user.nick, SOFT_PENALTY, m)
    end
  end
end
