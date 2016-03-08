class RecipesController < ApplicationController

  def index
  end

  def new
    @user = User.find(params[:user_id])
    @recipe = Recipe.new
  end

  def create

  end

  def show
  end


end
