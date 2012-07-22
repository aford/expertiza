require 'test_helper'

class Log4rLoggersControllerTest < ActionController::TestCase
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
      post :create, :log4r_logger => { }
    end

    assert_redirected_to log4r_logger_path(assigns(:log4r_logger))
  end

  test "should show log4r_logger" do
    get :show, :id => log4r_loggers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => log4r_loggers(:one).to_param
    assert_response :success
  end

  test "should update log4r_logger" do
    put :update, :id => log4r_loggers(:one).to_param, :log4r_logger => { }
    assert_redirected_to log4r_logger_path(assigns(:log4r_logger))
  end

  test "should destroy log4r_logger" do
    assert_difference('Log4rLogger.count', -1) do
      delete :destroy, :id => log4r_loggers(:one).to_param
    end

    assert_redirected_to log4r_loggers_path
  end
end
