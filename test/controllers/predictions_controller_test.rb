require 'test_helper'

class PredictionsControllerTest < ActionDispatch::IntegrationTest
  test "should display all records" do
    get predictions_path
    assert_response :success
  end

  test "should show result of prediction" do
    get predictions_path, params: { prediction: { id: 1 } }
    assert_response :success
  end

  test "should get new form" do
    get new_prediction_path
    assert_response :success
  end

=begin
  test "should create prediction" do
    assert_difference('Prediction.count') do
      post predictions_url, params: { prediction: { height: 45.3, weight: 123 } }
    end

    assert_redirected_to predictions_path(Prediction.last)
  end


  test "should get update" do
    put prediction_path, params: { prediction: { id: 1, is_dog_person:1 } }
    assert_response :success
  end
=end

  test "should display result after user selects actual value" do
    get predictions_path, params: { prediction: { id: 1 } }
    assert_response :success
  end


end
