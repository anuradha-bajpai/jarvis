class PredictionsController < ApplicationController
  IMAGE_DOG_PREDICT = "/assets/dog1.jpg"
  IMAGE_CAT_PREDICT = "/assets/cat2.jpg"
  IMAGE_DOG_LEARNING = "/assets/dog2.jpg"
  IMAGE_CAT_LEARNING = "/assets/cat1.jpg"

  def index
    @prediction = Prediction.all
  end

  def show
    @prediction = Prediction.find(params[:id])
    if(@prediction.prediction == 1)
      @image = IMAGE_DOG_PREDICT
    else
      @image = IMAGE_CAT_PREDICT
    end
  end

  def new
    @prediction = Prediction.new
  end

  def create
    @prediction = Prediction.new(prediction_param)
    @prediction.prediction = Prediction.new.predict(params[:height], params[:weight])

    if @prediction.save
      redirect_to @prediction
    else
      render 'new'
    end
  end

  def update
    if !Prediction.new.is_right_prediction(params[:id], params[:is_dog_person])
      @prediction = Prediction.find(params[:id])
      if(@prediction.is_dog_person == 1)
        @image = IMAGE_CAT_LEARNING
      else
        @image = IMAGE_DOG_LEARNING
      end
      render 'learning'
    end
  end

  def learning
  end

  private
  def prediction_param
    params.require(:@prediction).permit(:height, :weight)
  end

  private
  def update_prediction_param
    params.permit(:is_dog_person)
  end
end
