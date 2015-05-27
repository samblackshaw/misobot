#===============================================================================
# tokens.rb
#
# Implements a stream currency system.
#
# Dependencies:
# - MisoHelper
# - ActiveSupport
# - ActiveRecord
#===============================================================================

# Base Tokens class to kickstart automated processes and store persistent data.
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
        MisoHelper.refresh_active_users
        MisoHelper.active_users.each_key do |name|
          user = User.find_by(name: name) || User.create(name: name)
          user.update_attributes(tokens: user.tokens + INCREMENT_BY)
        end
      end
    end
  end
end

# Display current number of tokens.
# @command !mytokens
class Tokens::MyTokens
  include Cinch::Plugin
  match "mytokens"

  def execute(m)
    user = User.find_by(name: m.user.nick) || User.create(name: m.user.nick)
    m.twitch "@#{user.name}, you have #{user.tokens} #{Tokens::NAME}."
  end
end

# Penalize tokens from a user. Only mods are able to use this command.
# @command !penalize {username}
class Tokens::Penalize
  include Cinch::Plugin
  match /penalize.*/

  def execute(m)
    if MisoHelper.is_mod? m.user.nick
      params = m.params[-1].split(" ")
      penalize(params[1], PENALIZE_BY, m) if params.count == 2
    else
      m.twitch "SwiftRage @#{m.user.nick}, you ain't no mod!"
      penalize(m.user.nick, SOFT_PENALTY, m)
    end
  end

  # Removes {amount} from {username}'s token value. Value cannot dip below 0.
  # @param {string}  - username
  # @param {integer} - amount
  # @param {message} - m
  def penalize(username, amount, m)
    user = User.find_by(name: username) || User.create(name: username)

    # Deduct amount from number of tokens
    tokens = user.tokens - amount; tokens = 0 if tokens < 0
    user.update_attributes(tokens: tokens)
    m.twitch "SMOrc @#{user.name}, you have been penalized #{amount} " +
             "#{Tokens::NAME}."
  end
end
