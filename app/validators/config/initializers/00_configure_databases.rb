require 'stitch_fix/db_connections'
require 'stitch_fix/core_models/stitch_fix_model'

shared_db_env = if ENV['USE_RW_SHARED_DB'] == 'true'
                  'TRANSMETROPOLITAN_DATABASE_URL' # actually the master R/W database
                else
                  'TRANSMETROPOLITAN_ENG_REPLICA_DATABASE_URL' # attached as a follower, so by default we don't use the R/W database
                end

APP_DATABASES = [
    StitchFix::DbConnections::AppDatabase.new(
        klass:              StitchFix::SharedModel,
        connection_url_env: shared_db_env,
        structure_filename: "shared_structure.sql"),
    StitchFix::DbConnections::AppDatabase.new(
        klass:              ActiveRecord::Base,
        connection_url_env: "DATABASE_URL",
        structure_filename: "structure.sql")
]

APP_DATABASES.each(&:connect!)
