# Jarvis

Jarvis is a supervised machine learning app built in Ruby on Rails. This app takes in a person's height and weight and then guesses if that person likes dogs or cats better.

For this app, I have used Support Vector Machine (SVM) machine learning algorithm.

The game of prediction can be played at the root url. To visualize the classifier in SVM Supervised machine learning model and latest 5 accuracy metric graphs, check /admin/predictions.

* Version - Ruby 2.3.3, Rails 5.0.0.1
  
* Required gems - rb-libsvm (Machine Learning Algorithm is Support Vector Machine), bootstrap, bootstrap-saas, chartkick, sucker_punch

* Database - sqlite3 

* App Server - Puma 

* Database initialization - Initialize database with seed.rb to display graphs of classification data

* Services - Application Job to re-train model in a seperate thread using gem sucker_punch. It runs in a seperate thread with a delay of 30 seconds from main thread. 

* Configuration - Training data and trained model is at /training_data.
