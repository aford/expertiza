class Log4rLogger < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name, :log_level
end
