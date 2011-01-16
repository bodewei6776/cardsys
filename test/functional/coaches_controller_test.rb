require 'test_helper'

class CoachesControllerTest < ActionController::TestCase
  setup do
    @coach = coaches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:coaches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create coach" do
    assert_difference('Coach.count') do
      post :create, :coach => @coach.attributes
    end

    assert_redirected_to coach_path(assigns(:coach))
  end

  test "should show coach" do
    get :show, :id => @coach.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @coach.to_param
    assert_response :success
  end

  test "should update coach" do
    put :update, :id => @coach.to_param, :coach => @coach.attributes
    assert_redirected_to coach_path(assigns(:coach))
  end

  test "should destroy coach" do
    assert_difference('Coach.count', -1) do
      delete :destroy, :id => @coach.to_param
    end

    assert_redirected_to coaches_path
  end
end
