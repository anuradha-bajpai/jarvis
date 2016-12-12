require 'libsvm'
require 'libsvm/node'
require 'csv'

class Prediction < ApplicationRecord
  validates :height, presence: true,
            numericality: {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 250  }
  validates :weight, presence: true,
            numericality: { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 500  }

  log = Logger.new(STDOUT)
  log.level = Logger::DEBUG

  PATH_TO_TRAINING_DATA = "/training_data/training_data.csv"
  PATH_TO_TRAINED_MODEL = "/training_data/svm_trained_model.csv"

  # Predict classifier value based on input
  def predict(height, weight)
    logger.debug("Entering Predict Function with Height: #{height} and weight: #{weight}")

    #load trained model from disk
    savedmodel = Libsvm::Model.load(File.join(Rails.root,PATH_TO_TRAINED_MODEL))

    # predict classifier result
    prediction = savedmodel.predict(Libsvm::Node.features(height, weight))
    logger.debug("Exiting Predict Function with Prediction: #{prediction}")

    return prediction
  end

  # Save the actual value of 'is_dog_person'.
  # If the predicted != actual value, retrain model
  def is_right_prediction(id, is_dog_person)
    logger.debug("Entering is_right_prediction Function with id: #{id} and is_dog_person: #{is_dog_person}")

    # Update row with actual value for the prediction already saved in DB
    prediction = Prediction.find(id)
    prediction.update_columns(is_dog_person:is_dog_person)

    # retrain model. In case lib has retrain function,
    # it needs to be called only when actual != predicted
    # Perform retraining in a new thread for better performance. This thread is delayed by 30 seconds
    TrainModelJob.perform_in(30,prediction.id, prediction.height, prediction.weight, prediction.is_dog_person)

    predicted = prediction.prediction.to_s
    actual = prediction.is_dog_person.to_s
    logger.debug("Exiting is_right_prediction Function with result: #{(actual == predicted)? true : false}")

    return  (actual == predicted) ? true : false
  end


  # Alternative to calculate accuracy if the lib has retrain api
  # Not used currently
  def calculate_accuracy(predictions)
    total = 0
    correctness = 0
    predictions.each do |pred|
      if pred.is_dog_person.present? and pred.prediction.present?
        total= total+1
        predicted = pred.prediction
        actual = pred.is_dog_person
        if(predicted == actual)
          correctness = correctness+1
        end
      end
    end

    accuracy = correctness.to_f/total
    return "%.2f" % accuracy
  end
end
