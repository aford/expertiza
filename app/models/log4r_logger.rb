class Log4rLogger < ActiveRecord::Base
  validates_uniqueness_of :name
end
