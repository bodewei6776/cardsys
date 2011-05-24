require 'test_helper'

class RentsControllerTest < ActionController::TestCase
  setup do
    @rent = rents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rent" do
    assert_difference('Rent.count') do
      post :create, :rent => @rent.attributes
    end

    assert_redirected_to rent_path(assigns(:rent))
  end

  test "should show rent" do
    get :show, :id => @rent.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @rent.to_param
    assert_response :success
  end

  test "should update rent" do
    put :update, :id => @rent.to_param, :rent => @rent.attributes
    assert_redirected_to rent_path(assigns(:rent))
  end

  test "should destroy rent" do
    assert_difference('Rent.count', -1) do
      delete :destroy, :id => @rent.to_param
    end

    assert_redirected_to rents_path
  end
end
