class RecipesController < ApplicationController

  def index
  end

  def new
    @user = User.find(params[:user_id])
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params[:recipe])

    if @recipe.save
      redirect_to user_recipe_path(user_id: params[:user_id], id: @recipe.id)
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:user_id])
    @recipe = Recipe.find(params[:id])
  end

  private

  def recipe_params
    params.permit(recipe:[:name])
  end


end
