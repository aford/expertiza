require File.dirname(__FILE__) + '/../test_helper'
require 'yaml'

class Log4rLoggersControllerTest < ActionController::TestCase
  fixtures :log4r_loggers
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:log4r_loggers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create log4r_logger" do
    assert_difference('Log4rLogger.count') do
      post :create, :log4r_logger => {:name => "logger1", :log_level => "DEBUG" }
    end

    assert_redirected_to log4r_logger_path(assigns(:log4r_logger))
  end

  test "should show log4r_logger" do
    get :show, :id => log4r_loggers(:logger1).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => log4r_loggers(:logger1).to_param
    assert_response :success
  end

  test "should update log4r_logger" do
    put :update, :id => log4r_loggers(:logger1).to_param, :log4r_logger => { :name => "logger2", :log_level => "DEBUG" }
    assert_redirected_to log4r_logger_path(assigns(:log4r_logger))
  end

  test "should destroy log4r_logger" do
    assert_difference('Log4rLogger.count', -1) do
      delete :destroy, :id => log4r_loggers(:logger1).to_param
    end

    assert_redirected_to log4r_loggers_path
  end
  
  test "formatter not null" do
    formatter = Log4rLoggersHelper::get_formatter
    assert_not_nil formatter
  end
  
  test "logger not null" do
    logger = Log4rLoggersHelper::get_logger(log4r_loggers(:logger2))
    assert_not_nil logger
  end
  
  test "pre_config not null" do
    pre_config = Log4rLoggersHelper::get_pre_config
    assert_not_nil pre_config
  end
  
  test "default_level not null" do
    default_level = Log4rLoggersHelper::get_default_level
    assert_not_nil default_level
  end
  
  test "custom_levels not null" do
    custom_levels = Log4rLoggersHelper::get_custom_levels
    assert_not_nil custom_levels
  end
  
end
