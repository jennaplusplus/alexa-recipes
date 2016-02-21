class WelcomeController < ApplicationController
  def index
  end

  def ask
    response = {
      "version": "0.1.1",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": "Welcome to recipes!"
        },
        "card": null,
        "reprompt": null,
        "shouldEndSession": true
      },
      "sessionAttributes": {}
    }

    render :json => response.as_json, status: :ok
  end
end
