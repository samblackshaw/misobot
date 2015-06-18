#===============================================================================
# misohelper.rb
#
# Include this module in a Misobot plugin to use its helper methods.
#===============================================================================

module MisoHelper

  # Returns whether a user exists or not, regardless of if an @ handle is used.
  # @param {string} - username
  # @return {boolean} - true if exists, false otherwise
  def user_exists?(username)
    username.gsub!("@", "")
    user = User.find_by(name: username)
    !user.blank?
  end

  # Returns array of parameters given a message object.
  # @param  {message} - m
  # @return {array}
  def extract_params(m)
    params = m.params[-1].split(" ")
    params.shift
    params
  end

  # Formats a username for it to be safe to use in methods.
  # @param  {string} - username
  # @return {string}
  def format_username(username)
    username.downcase.gsub("@", "")
  end

end
