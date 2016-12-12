require 'test_helper'
require 'libsvm'
require 'libsvm/node'

class PredictionTest < ActiveSupport::TestCase

  PATH_TO_TRAIN_DATA = "/training_data/training_data.csv"
  PATH_TO_TRAINED_MODEL = "/training_data/svm_trained_model.csv"

  test "should not save prediction without height and weight" do
    prediction = Prediction.new
    assert_not prediction.save, "Saved the prediction without height and weight"
  end

  test "should not save prediction with non-numerical values in height and weight" do
    prediction = Prediction.new(height: "height", weight: "weight")
    assert_not prediction.save, "Saved prediction with non-numerical values in height and weight"
  end

  test "should not save height and weight with values lesser than 0" do
    prediction = Prediction.new(height: -2, weight: -1)
    assert_not prediction.save, "Saved prediction with values lesser than 0 in height and weight"
  end

  test "should not save height greater than 250 and weight greater than 500" do
    prediction = Prediction.new(height: 300, weight:700 )
    assert_not prediction.save, "Saved prediction with values lesser than 0 in height and weight"
  end

  test "model should return boolean if the prediction was correct or not" do
    p =  Prediction.new.is_right_prediction(Prediction.last.id, 1)
    assert_not_nil p, "Model did not update actual value"
  end

  test "model should predict if the someone is dog or cat person based on height and weight" do
    p = Prediction.new.predict(72.2, 230)
    assert_not_nil p, "Model did not predict any value"
  end
end
