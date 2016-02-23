class WelcomeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @recipe = Recipe.first
  end

  def ask
    response = {
      "version": "0.1.1",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": "Hello world!"
        },
        "card": nil,
        "reprompt": nil,
        "shouldEndSession": true
      },
      "sessionAttributes": {}
    }

    render :json => response.as_json, status: :ok
  end
end
