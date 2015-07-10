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

  # Updates {username}'s balance by {amount}. New balance cannot dip below 0.
  # @param  {string}  - username
  # @param  {integer} - amount
  def self.update(username, amount)
    user        = User.find_or_create_by(name: username)
    new_balance = user.tokens + amount
    new_balance = 0 if new_balance < 0
    user.update_attributes(tokens: new_balance)
  end

  # Returns whether {username} has at least {amount} in their balance.
  # @param {string}  - username
  # @param {integer} - amount
  def self.has_at_least?(username, amount)
    user = User.find_by(name: username)
    if !user.blank?
      return user.tokens >= amount
    else
      return false
    end
  end
end

# Display current number of tokens.
# @command !mytohkens
class Tokens::MyTokens
  include Cinch::Plugin
  include MisoHelper
  match "mytohkens"

  def execute(m)
    user = User.find_or_create_by(name: format_username(m.user.nick))
    m.twitch_colored "@#{user.name}, you have #{user.tokens} #{Tokens::NAME}"
  end
end

# Give tokens to another user.
# @command !givetohkens {username} {amount}
class Tokens::GiveTokens
  include Cinch::Plugin
  include MisoHelper
  match /givetohkens.*/

  def execute(m)
    params = extract_params(m)
    if params.count == 2

      # Spell out params
      giver_name    = format_username(m.user.nick)
      receiver_name = format_username(params.first)
      xfer_amount   = params.last.to_i

      # Check if {username} exists
      if user_exists?(receiver_name)

        # Check if transfer amount is a positive integer or naw
        if xfer_amount > 0

          # Check if giver has required amount
          if Tokens.has_at_least?(giver_name, xfer_amount)
            Tokens.update(giver_name, -xfer_amount)
            Tokens.update(receiver_name, xfer_amount)
            m.twitch_colored "@#{giver_name} gave @#{receiver_name} " +
              "#{xfer_amount} #{Tokens::NAME}, what a kind person! :)"

          else # {username} doesn't have enough tokens
            m.twitch_colored "@#{giver_name}, you don't have that many " +
                     "#{Tokens::NAME} to give!"
          end

        # Catch people trolling
        elsif xfer_amount == 0
          m.twitch_colored "@#{giver_name}, stop trolling pls or I will destroy"

        # Catch people trying to exploit the system
        else
          m.twitch_colored "Nice try, @#{giver_name}, get timed out"
          m.twitch_colored "/timeout #{giver_name} 60"
        end

      else # Receiver does not exist
        m.twitch_colored "#{receiver_name} doesn't have a #{Tokens::NAME} " +
          "account yet, boo :("
      end

    else # User incorrectly typed command
      m.twitch_colored "Usage: !givetohkens {username} {amount}"
    end
  end
end

# Penalize tokens from a user. Only mods are able to use this command.
# @command !penalizetohkens {username}
class Tokens::PenalizeTokens
  include Cinch::Plugin
  include MisoHelper
  match /penalizetohkens.*/

  def execute(m)
    if MisoSTM.is_mod? m.user.nick
      params = extract_params(m)
      if params.count == 1

        # Spell out params
        username = format_username(params.first)

        # Penalize if {username} exists
        if user_exists?(username)
          Tokens.update(username, -Tokens::PENALIZE_BY)
          m.twitch_colored "SMOrc @#{username}, you have been penalized " +
            "#{Tokens::PENALIZE_BY} #{Tokens::NAME}."

        else # {username} doesn't exist
          m.twitch_colored "Ayo, #{username} doesn't have a #{Tokens::NAME} " +
            "account"
        end

      else # Mod incorrectly typed command
        m.twitch_colored "Usage: !penalizetohkens {username}"
      end

    else # User is not a mod
      m.twitch_colored "SwiftRage @#{m.user.nick}, you ain't no mod! Get " +
        "penalized"
      Tokens.update(m.user.nick, -Tokens::SOFT_PENALTY)
      m.twitch_colored "SMOrc @#{m.user.nick}, you have been penalized " +
        "#{Tokens::SOFT_PENALTY} #{Tokens::NAME}"
    end
  end
end
