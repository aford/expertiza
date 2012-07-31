class InitializeLog4rLoggers < ActiveRecord::Migration
  def self.up
    create_table :log4r_loggers do |t|
      t.string :name
      t.string :log_level

      t.timestamps
    end
    
    execute "INSERT INTO log4r_loggers(name, log_level, created_at) VALUES ('assignments', 'NONE', SYSDATE())"
    execute "INSERT INTO log4r_loggers(name, log_level, created_at) VALUES ('teams', 'NONE', SYSDATE())"
    execute "INSERT INTO log4r_loggers(name, log_level, created_at) VALUES ('reviews', 'NONE', SYSDATE())"
    execute "INSERT INTO log4r_loggers(name, log_level, created_at) VALUES ('responses', 'NONE', SYSDATE())"

  end

  def self.down
    drop_table :log4r_loggers
  end
end
