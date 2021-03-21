# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery
  # for now, disable authentication and authorization as this is not fully implemented yet.
  # we don't need security yet as we are only converting tables to different formats and not storing any data.
  
  # before_action :authenticate_user!
end
