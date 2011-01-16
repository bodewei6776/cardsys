require 'test_helper'

class CommonResourcesControllerTest < ActionController::TestCase
  setup do
    @common_resource = common_resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:common_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create common_resource" do
    assert_difference('CommonResource.count') do
      post :create, :common_resource => @common_resource.attributes
    end

    assert_redirected_to common_resource_path(assigns(:common_resource))
  end

  test "should show common_resource" do
    get :show, :id => @common_resource.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @common_resource.to_param
    assert_response :success
  end

  test "should update common_resource" do
    put :update, :id => @common_resource.to_param, :common_resource => @common_resource.attributes
    assert_redirected_to common_resource_path(assigns(:common_resource))
  end

  test "should destroy common_resource" do
    assert_difference('CommonResource.count', -1) do
      delete :destroy, :id => @common_resource.to_param
    end

    assert_redirected_to common_resources_path
  end
end
