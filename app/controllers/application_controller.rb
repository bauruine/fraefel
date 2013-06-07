# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :user_setup

  protected

  def user_setup
    User.current = current_user
    Authorization.current_user = current_user
  end

end
