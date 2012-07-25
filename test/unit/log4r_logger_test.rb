require File.dirname(__FILE__) + '/../test_helper'

class Log4rLoggerTest < ActiveSupport::TestCase
  # test valid logger
  def test_valid_logger
    l = Log4rLogger.new
    l.name = "logger"
    l.log_level = "DEBUG"
    assert l.save
  end

  # test no name logger
  def test_no_name_logger
    l = Log4rLogger.new
    l.log_level = "DEBUG"
    assert !l.save
  end
  
  # test duplicate name logger
  def test_duplicate_name_logger
    l = Log4rLogger.new
    l.name = "logger"
    l.log_level = "DEBUG"
    l.save
    
    l = Log4rLogger.new
    l.name = "logger"
    l.log_level = "DEBUG"
    l.save
    assert !l.save
  end
  
  # test duplicate log_level logger
  def test_duplicate_log_level_logger
    l = Log4rLogger.new
    l.name = "logger"
    l.log_level = "DEBUG"
    l.save
    
    l = Log4rLogger.new
    l.name = "logger2"
    l.log_level = "DEBUG"
    l.save
    assert l.save
  end

  # test no log_level logger
  def test_no_log_level_logger
    l = Log4rLogger.new
    l.name = "logger"
    assert !l.save
  end
  
end
