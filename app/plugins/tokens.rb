#===============================================================================
# tokens.rb
#
# Implements a stream currency system.
#===============================================================================

# Display current number of tokens.
# @command !mytokens
#-------------------------------------------------------------------------------
class Tokens
  include Cinch::Plugin
  match "mytokens"

  NAME = "Tohfoo Tokens"

  def execute(m)
    user = User.find_by(name: m.user.nick) || User.create(name: m.user.nick)
    m.twitch "@#{user.name}, you have #{user.tokens} #{Tokens::NAME}."
  end
end

# Penalize tokens from a user. Only mods are able to use this command.
# @command !penalize {username}
#-------------------------------------------------------------------------------
class Tokens::Penalty
  include Cinch::Plugin
  match /penalize.*/

  def execute(m)

    # Is a mod
    if MisoHelper.is_mod? m.user.nick
      params = m.params[-1].split(" ")
      penalize(params[1], 10, m) if params.count == 2

    # Is not a mod
    else
      m.twitch "SwiftRage @#{m.user.nick}, you ain't no mod!"
      penalize(m.user.nick, 5, m)
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
