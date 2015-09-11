#===============================================================================
# queues.rb
#
# Implements a dynamic queuing system.
#
# Dependencies:
# - MisoSTM
# - ActiveSupport
# - ActiveRecord
#===============================================================================

# Base Queues class to store temporary data and methods that can be used
# in all Queue-related plugins.
class Queues
  @@challengers      = []
  @@challengers_open = false

  def self.challengers
    @@challengers
  end

  def self.challengers_open?
    @@challengers_open
  end

  def self.add_challenger(user)
    @@challengers << user
  end

  def self.remove_challenger(user)
    @@challengers.delete user
  end

  def self.open_challengers_line
    @@challengers_open = true
  end

  def self.close_challengers_line
    @@challengers_open = false
  end

  def self.clear_challengers_line
    @@challengers = []
  end

  def self.next_challenger
    @@challengers.shift
  end
end

# Open line.
# @command !openlist
class Queues::OpenList
  include Cinch::Plugin
  include MisoHelper
  match "openlist"

  def execute(m)
    user = format_username(m.user.nick)

    # Only streamer can use command
    if user == ENV["TWITCH_USER"]

      # Check if line is closed
      if !Queues.challengers_open?
        Queues.open_challengers_line
        m.twitch_colored "Challenger line is open!"
      else
        m.twitch_colored "Line's already open tho"
      end
    else
      m.twitch_colored "Sorry, only #{ENV['TWITCH_USER']} can use this command"
    end
  end
end

# Close line.
# @command !closelist
class Queues::CloseList
  include Cinch::Plugin
  include MisoHelper
  match "closelist"

  def execute(m)
    if MisoSTM.is_mod? m.user.nick
      if Queues.challengers_open?
        Queues.close_challengers_line
        m.twitch_colored "Line's closed! Womp womp"
      else
        m.twitch_colored "Line's already closed tho"
      end
    else
      m.twitch_colored "Sorry, only mods can use this command"
    end
  end
end

# Clear line.
# @command !clearlist
class Queues::ClearList
  include Cinch::Plugin
  include MisoHelper
  match "clearlist"

  def execute(m)
    user = format_username(m.user.nick)

    # Only streamer can use command
    if user == ENV["TWITCH_USER"]
      Queues.clear_challengers_line
      m.twitch_colored "Line has been cleared-a-roonies"
    else
      m.twitch_colored "Sorry, only #{ENV['TWITCH_USER']} can use this command"
    end
  end
end

# Show line.
# @command !list
class Queues::List
  include Cinch::Plugin
  include MisoHelper
  match "list"

  def execute(m)
    user = format_username(m.user.nick)

    # Check to see if there are people in line
    if Queues.challengers.count > 0
      m.twitch_colored "The challenger line is: #{Queues.challengers.join(', ')}"
    else
      m.twitch_colored "Line's empty!"
    end
  end
end

# See spot in line.
# @command !spot
class Queues::Spot
  include Cinch::Plugin
  include MisoHelper
  match "spot"

  def execute(m)
    user = format_username(m.user.nick)

    # Get index of your username in challengers list
    spot = Queues.challengers.find_index(user)

    if !spot.nil?
      m.twitch_colored "@#{user}, you are #{(spot + 1).ordinalize} in line"
    else
      m.twitch_colored "@#{user}, you ain't in line doe"
    end
  end
end

# Move line.
# @command !callnext
class Queues::CallNext
  include Cinch::Plugin
  include MisoHelper
  match "callnext"

  def execute(m)
    if MisoSTM.is_mod? m.user.nick
      next_challenger = Queues.next_challenger
      if !next_challenger.blank?
        m.twitch_colored "@#{next_challenger}, you're now up :)"
      else
        m.twitch_colored "We're at the end of the line, peeps"
      end
    end
  end
end

# Attempt to join challenger line.
# @command !join
class Queues::Join
  include Cinch::Plugin
  include MisoHelper
  match "join"

  def execute(m)
    user = format_username(m.user.nick)

    # Make sure the line is open
    if Queues.challengers_open?

      # Make sure the line doesn't have the user
      if !Queues.challengers.include? user
        Queues.add_challenger user
        m.twitch_colored "@#{user}, you've been added to the challenger line! " +
          "You are currently #{Queues.challengers.count.ordinalize} " +
          "in line"
      else
        m.twitch_colored "@#{user}, you in da challenger line already doe. Wait " +
          "yo turn"
      end
    else
      m.twitch_colored "Sorry, challenger line is currently not open :("
    end
  end
end

# Leave challenger line.
# @command !leave
class Queues::Leave
  include Cinch::Plugin
  include MisoHelper
  match "leave"

  def execute(m)
    user = format_username(m.user.nick)

    # Make sure the line has the user
    if Queues.challengers.include? user
      Queues.remove_challenger user
      m.twitch_colored "@#{user}, you've been successfully removed from the " +
        "challenger line"
    else
      m.twitch_colored "@#{user}, you're not in line, so you good"
    end
  end
end
