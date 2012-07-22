class InitializeLog4rLoggers < ActiveRecord::Migration
  def self.up
    create_table :log4r_loggers do |t|
      t.string :name
      t.boolean :is_enabled

      t.timestamps
    end
    
    execute "INSERT INTO log4r_loggers(name, is_enabled, created_at) VALUES ('debugr', false, SYSDATE())"
    execute "INSERT INTO log4r_loggers(name, is_enabled, created_at) VALUES ('assignment', false, SYSDATE())"
    execute "INSERT INTO log4r_loggers(name, is_enabled, created_at) VALUES ('team', false, SYSDATE())"
    execute "INSERT INTO log4r_loggers(name, is_enabled, created_at) VALUES ('review', false, SYSDATE())"
    execute "INSERT INTO log4r_loggers(name, is_enabled, created_at) VALUES ('author_feedback', false, SYSDATE())"
    execute "INSERT INTO log4r_loggers(name, is_enabled, created_at) VALUES ('teammate_review', false, SYSDATE())"

  end

  def self.down
    drop_table :log4r_loggers
  end
end
