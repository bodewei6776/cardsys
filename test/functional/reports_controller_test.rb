require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  test "should get coach" do
    get :coach
    assert_response :success
  end

  test "should get income" do
    get :income
    assert_response :success
  end

  test "should get member_cosume_detail" do
    get :member_cosume_detail
    assert_response :success
  end

  test "should get court_usage" do
    get :court_usage
    assert_response :success
  end

end
