=begin
  app/controllers/application_controller.rb
  Created By:   Ashutosh Sharma
  Created Date: June 07, 2016
  Description:  Application Controller
=end
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception
end
