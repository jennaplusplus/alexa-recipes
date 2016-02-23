class WelcomeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @recipe = Recipe.first
  end

  def ask
    response = Recipe.router(params)
    render :json => response.as_json, status: :ok
  end
end
