class RecipesController < ApplicationController

  def index
    @recipes = current_user.recipes
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = current_user.recipes.new(recipe_params[:recipe])

    if @recipe.save
      redirect_to user_recipe_path(user_id: current_user, id: @recipe.id)
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
