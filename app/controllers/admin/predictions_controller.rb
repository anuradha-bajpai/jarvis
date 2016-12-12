class Admin::PredictionsController < ApplicationController
  def index
    @dog_person_json = Prediction.where(is_dog_person: 1).pluck(:height, :weight).to_json
    @cat_person_json = Prediction.where(is_dog_person: 0).pluck(:height, :weight).to_json

    @accuracy = Prediction.last(5).map(&:metric_1).to_json
  end
end
