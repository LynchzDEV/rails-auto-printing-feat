require "test_helper"

class PrintControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get print_index_url
    assert_response :success
  end
end
