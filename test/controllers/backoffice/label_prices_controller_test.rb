require "test_helper"

class Backoffice::LabelPricesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get backoffice_label_prices_index_url
    assert_response :success
  end
end
