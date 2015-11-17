#===============================================================================
# User Model
#===============================================================================

# Dependencies
#-------------------------------------------------------------------------------
mongoose     = require "mongoose"
Schema       = mongoose.Schema
findOrCreate = require "mongoose-findorcreate"


# Model Definition
#-------------------------------------------------------------------------------
UserSchema = new Schema
  name:   String
  tokens: Number

# Add findOrCreate plugin
UserSchema.plugin findOrCreate
User = mongoose.model "user", UserSchema


# Export
#-------------------------------------------------------------------------------
module.exports = User
