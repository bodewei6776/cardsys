require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should get backup" do
    get :backup
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

end
