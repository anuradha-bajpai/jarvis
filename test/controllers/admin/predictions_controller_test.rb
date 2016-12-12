require 'test_helper'

class Admin::PredictionsControllerTest < ActionDispatch::IntegrationTest
  test "should show admin index page" do
    get admin_predictions_path
    assert_response :success
  end

end
