class Recipe
  include Mongoid::Document
  field :name, type: String

  def self.begin(params)
    if params["type"] == "LaunchRequest"
      response = {
        "version": "0.1.1",
        "response": {
          "outputSpeech": {
            "type": "PlainText",
            "text": "Welcome to Recipes! Would you like a list of ingredients for this recipe?"
          },
          "card": nil,
          "reprompt": nil,
          "shouldEndSession": true
        },
        "sessionAttributes": {}
      }
      return response
    end


  end


end
