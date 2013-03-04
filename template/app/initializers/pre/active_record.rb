ActiveRecord::Base.logger = Sharp.logger
ActiveRecord::Base.establish_connection Sharp.config.database[:default]
