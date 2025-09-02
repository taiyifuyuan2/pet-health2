require "test_helper"

class HouseholdsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get households_show_url
    assert_response :success
  end

  test "should get update" do
    get households_update_url
    assert_response :success
  end
end
