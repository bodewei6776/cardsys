require 'test_helper'

class LockersControllerTest < ActionController::TestCase
  setup do
    @locker = lockers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lockers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create locker" do
    assert_difference('Locker.count') do
      post :create, :locker => @locker.attributes
    end

    assert_redirected_to locker_path(assigns(:locker))
  end

  test "should show locker" do
    get :show, :id => @locker.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @locker.to_param
    assert_response :success
  end

  test "should update locker" do
    put :update, :id => @locker.to_param, :locker => @locker.attributes
    assert_redirected_to locker_path(assigns(:locker))
  end

  test "should destroy locker" do
    assert_difference('Locker.count', -1) do
      delete :destroy, :id => @locker.to_param
    end

    assert_redirected_to lockers_path
  end
end
