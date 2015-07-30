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

  # Returns the hours:minutes:seconds difference between two Time objects.
  # http://stackoverflow.com/questions/19595840/rails-get-the-time-difference-in-hours-minutes-and-seconds
  # @param  {Time} - start_time
  # @param  {Time} - end_time
  # @return {string}
  def time_diff(start_time, end_time)
    seconds_diff  = (start_time - end_time).to_i.abs
    hours         = seconds_diff / 3600
    seconds_diff -= hours * 3600
    minutes       = seconds_diff / 60
    seconds_diff -= minutes * 60
    seconds       = seconds_diff
    "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end

end
