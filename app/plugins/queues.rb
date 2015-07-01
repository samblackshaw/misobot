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
end

# Open line.
# @command !openline
class Queues::Open
  include Cinch::Plugin
  include MisoHelper
  match "openline"

  def execute(m)
    user = format_username(m.user.nick)

    # Only streamer can use command
    if user == ENV["TWITCH_USER"]

      # Check if line is closed
      if !Queues.challengers_open
        Queues.challengers_open = true
        m.twitch "Line's open!"
      else
        m.twitch "Line's already open tho"
      end
    else
      m.twitch "Sorry, only #{ENV['TWITCH_USER']} can use this command"
    end
  end
end

# Close line.
# @command !closeline
class Queues::Close
  include Cinch::Plugin
  include MisoHelper
  match "closeline"

  def execute(m)
    user = format_username(m.user.nick)

    # Only streamer can use command
    if user == ENV["TWITCH_USER"]

      # Check if line is open
      if Queues.challengers_open
        Queues.challengers_open = false
        m.twitch "Line's closed! Womp womp"
      else
        m.twitch "Line's already closed tho"
      end
    else
      m.twitch "Sorry, only #{ENV['TWITCH_USER']} can use this command"
    end
  end
end

# Clear line.
# @command !clearline
class Queues::Clear
  include Cinch::Plugin
  include MisoHelper
  match "clearline"

  def execute(m)
    user = format_username(m.user.nick)

    # Only streamer can use command
    if user == ENV["TWITCH_USER"]
      Queues.challengers = []
      m.twitch "Line has been cleared-a-roonies"
    else
      m.twitch "Sorry, only #{ENV['TWITCH_USER']} can use this command"
    end
  end
end

# Show line.
# @command !line
class Queues::Line
  include Cinch::Plugin
  include MisoHelper
  match "line"

  def execute(m)
    user = format_username(m.user.nick)

    # Make sure the line is open
    if Queues.challengers_open

      # Check to see if there are people in line
      if Queues.challengers.count > 0
        m.twitch "The challenger line is: #{Queues.challengers.join(', ')}"
      else
        m.twitch "Line's empty, now's your chance :)"
      end
    else
      m.twitch "Sorry, challenger line is currently not open :("
    end
  end
end

# Move line.
# @command !next
class Queues::Next
  include Cinch::Plugin
  include MisoHelper
  match "next"

  def execute(m)
    user = format_username(m.user.nick)

    # Only streamer can use command
    if user == ENV["TWITCH_USER"]

      # Make sure the line is open
      if Queues.challengers_open
        Queues.shift
        m.twitch "Next up, we have @#{Queues.challengers.first}, please be " +
                 "ready :)"
      else
        m.twitch "Line isn't open yet tho"
      end
    else
      m.twitch "Sorry, only #{ENV['TWITCH_USER']} can use this command"
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
    if Queues.challengers_open

      # Make sure the line doesn't have the user
      if !Queues.challengers.include? user
        Queues.challengers << user
        m.twitch "@#{user.name}, you've been added to the challenger line! " +
                 "You are currently #{Queues.challengers.count.ordinalize} " +
                 "in line"
      else
        m.twitch "@#{user.name}, you in da challenger line already doe. Wait " +
                 "yo turn"
      end
    else
      m.twitch "Sorry, challenger line is currently not open :("
    end
  end
end

# Leave challenger line.
# @command !unjoin
class Queues::Unjoin
  include Cinch::Plugin
  include MisoHelper
  match "unjoin"

  def execute(m)
    user = format_username(m.user.nick)

    # Make sure the line is open
    if Queues.challengers_open

      # Make sure the line has the user
      if Queues.challengers.include? user
        Queues.challengers.delete user
        m.twitch "#@#{user.name}, you've been successfully removed from the " +
                 "challenger line"
      else
        m.twitch "@#{user.name}, you're not in line"
      end
    else
      m.twitch "Line is closed, so no need to !unjoin, @#{user.name}"
    end
  end
end
