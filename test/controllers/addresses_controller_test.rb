require 'test_helper'

class AddressesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get addresses_index_url
    assert_response :success
  end

  test "should get new" do
    get addresses_new_url
    assert_response :success
  end

  test "should get create" do
    get addresses_create_url
    assert_response :success
  end
end
