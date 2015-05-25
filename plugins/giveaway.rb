#===============================================================================
# giveaway.rb
#
# Spits out a URL to a giveaway sign up form. To be replaced with a queue
# system after the 500 follower giveaway.
#===============================================================================

class Giveaway
  include Cinch::Plugin

  match "giveaway"

  def execute(m)
    m.twitch "Enter to win the 500 follower Amiibo giveaway! There will be 2 " +
             "winners! http://goo.gl/4gYsai"
  end
end
