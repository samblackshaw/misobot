#===============================================================================
# Rakefile
#===============================================================================

require "active_record"
require "yaml"
require "pg"


# Establish database connection
#-------------------------------------------------------------------------------
db_config = YAML::load(IO.read("app/config/database.yml"))
ActiveRecord::Base.establish_connection(db_config["production"])


# Migrate task
#-------------------------------------------------------------------------------
desc "Run migrations"
task :migrate do
  ActiveRecord::Migrator.migrate("app/db/migrate", nil)
end
