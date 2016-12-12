class TrainModelJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  log = Logger.new(STDOUT)
  log.level = Logger::DEBUG

  PATH_TO_TRAINING_DATA = "/training_data/training_data.csv"
  PATH_TO_TRAINED_MODEL = "/training_data/svm_trained_model.csv"

  # Retrain model and run cross validation n-fold validation to find model accuracy
  def perform(prediction_id,height, weight, is_dog_person)
    logger.debug("Entering TrainModeJob.perform function with id: #{prediction_id},
         height: #{height}, weight: #{weight}, is_dog_person: #{is_dog_person}")

    ActiveRecord::Base.connection_pool.with_connection do
      #Add new data for training
      update_training_data(height, weight, is_dog_person)

      #read training data from csv file
      row = IO.readlines(File.open(File.join(Rails.root,PATH_TO_TRAINING_DATA)), skip_blanks: true).map(&:strip).shuffle
      instances = row.map { |line| line.split(',') }

      # Create array of input nodes per instance
      input_params = instances.map { |instance|
        height, weight = *instance[0..1].map(&:to_f)
        Libsvm::Node.features(height, weight)
      }

      # Pluck class property (Cat or Dog Person)
      class_param = instances.map(&:last)

      # Deduplicate and assign indexes
      class_indexes  = class_param.to_set.to_a

      # Array of label indexes of instances
      labels = class_param.map { |label_name| class_indexes.index(label_name) }

      # Create problem traning set
      problem = Libsvm::Problem.new
      problem.set_examples(labels, input_params)

      # Build new model.
      parameter = Libsvm::SvmParameter.new
      parameter.cache_size  = 10 # in megabytes
      parameter.eps         = 0.00001
      parameter.degree      = 5
      parameter.gamma       = 0.01
      parameter.c           = 100
      parameter.kernel_type = Libsvm::KernelType.const_get(:LINEAR)

      model = Libsvm::Model.train(problem, parameter)

      #save model on disk
      model.save(File.join(Rails.root,PATH_TO_TRAINED_MODEL))

      #calculate accuracy
      accuracy = calculate_accuracy(problem, parameter,class_param,class_indexes)

      #update accuracy in DB
      save_accuracy(prediction_id, accuracy)
      logger.debug("Exiting TrainModeJob.perform function with model accuracy: #{accuracy}")
    end
  end

  # Update training data in csv
  private
    def update_training_data(height, weight, is_dog_person)
      logger.debug("Entering TrainModeJob.update_training_data function with
          Height: #{height}, weight: #{weight}, is_dog_person: #{is_dog_person}")
      if(height > 0)
        CSV.open(File.join(Rails.root,PATH_TO_TRAINING_DATA), "ab") do |csv|
          csv << ([height, weight, is_dog_person])
        end
      end
      logger.debug("Exiting TrainModeJob.update_training_data function")
    end

  # Calculate Model Accuracy using n-fold cross validation
  # TODO Replace this function with Predicton.calculateaccuracy to improve performance
  private
    def calculate_accuracy(problem, parameter,class_param,class_indexes)
      logger.debug("Entering TrainModeJob.calculate_accuracy function")
      nfold = 10
      result = Libsvm::Model.cross_validation(problem, parameter, nfold)

      predicted_name = result.map { |label| class_indexes[label] }
      correctness = predicted_name.map.with_index { |p, i| p == class_param[i] }

      correct = correctness.select { |x| x }
      accuracy = (correct.size.to_f / correctness.size)*100
      acc_str = "%.2f" % accuracy
      logger.debug("Exiting TrainModeJob.calculate_accuracy function
          Accuracy_type = :LINEAR, nfold = #{nfold} : #{acc_str}")
      return accuracy
    end

  # To analyze how accuracy is changing and display it on chart, persist accuracy
  private
    def save_accuracy(id, accuracy)
      logger.debug("Entering TrainModeJob.save_accuracy function id: #{id}, accuracy: #{accuracy}")
      if(id > 0)
        prediction = Prediction.find(id)
        prediction.update_columns(metric_1: accuracy)
      end
      logger.debug("Exiting TrainModeJob.save_accuracy")
    end
end
