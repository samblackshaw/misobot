#===============================================================================
# misostm.rb
#
# Stands for Miso Short Term Memory. Helper class that stores and manipulates
# data for the duration of a script execution.
#===============================================================================

class MisoSTM

  # Constants
  #-----------------------------------------------------------------------------
  IDLE_TIME  = 5.minutes
  START_TIME = Time.now


  # Class variables
  #-----------------------------------------------------------------------------
  @@moderators   = ENV["MODERATORS"].split(", ")
  @@active_users = {}


  # Moderators
  #-----------------------------------------------------------------------------
  # Returns list of mods.
  # @return {array}
  def self.mods
    @@moderators
  end

  # Concatenates a list of usernames to moderators list.
  # @param {array<string>} - mods
  def self.add_mods(mods)
    @@moderators += mods
  end

  # Returns whether a username is found in the moderators list.
  # @param {string} - name
  # @param {boolean}
  def self.is_mod?(name)
    @@moderators.include? name
  end


  # Active Users
  #-----------------------------------------------------------------------------
  # Returns list of active users.
  # @return {hash}
  def self.active_users
    @@active_users
  end

  # Update user in the active users list.
  # @param {string} - name
  def self.update_active_user(name)
    @@active_users[name] = DateTime.now if name != "jtv"
  end

  # Removes a user from the active users list.
  # @param {string} - name
  def self.remove_active_user(name)
    @@active_users.delete(name)
  end

  # Checks for idle users and removes them from the active users list.
  def self.refresh_active_users
    @@active_users.each do |name, time|
      self.remove_active_user(name) if time <= IDLE_TIME.ago
    end
  end
end
