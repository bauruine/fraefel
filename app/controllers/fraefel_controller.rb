# encoding: utf-8
class FraefelController < ApplicationController
  before_filter :authenticate_user!
end
