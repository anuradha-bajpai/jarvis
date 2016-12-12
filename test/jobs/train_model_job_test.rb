require 'test_helper'
require 'sucker_punch/testing/inline'

class TrainModelJobTest < ActiveJob::TestCase
  PATH_TO_TRAINED_MODEL = "/training_data/svm_trained_model.csv"

  test "should train model for the first time" do
    TrainModelJob.perform_async(Prediction.last.id,74.2, 250, 1)
    assert File.exist?(File.join(Rails.root,PATH_TO_TRAINED_MODEL)), "Model not available to predict"
  end

  test "should retrain model and latest accuracy in DB for the given prediction id" do
    TrainModelJob.perform_async(Prediction.last.id,74.2, 250, 1)
    # TODO Improvisation - Test by using 'model confidence'
    update_time = File.mtime(File.join(Rails.root,PATH_TO_TRAINED_MODEL))
    assert_equal Time.now.change(:sec => 0).to_s, update_time.change(:sec => 0).to_s, "Model did not update"
  end
end
