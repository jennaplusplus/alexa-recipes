class Recipe
  include Mongoid::Document
  field :name, type: String

  def self.begin(params)
    if params["request"]["type"] == "LaunchRequest"
      response = {
        "version": "0.1.1",
        "response": {
          "outputSpeech": {
            "type": "PlainText",
            "text": "Welcome to Recipes!"
          },
          "card": nil,
          "reprompt": nil,
          "shouldEndSession": true
        },
        "sessionAttributes": {}
      }
    elsif params["request"]["type"] == "IntentRequest"
      response = {
        "version": "0.1.1",
        "response": {
          "outputSpeech": {
            "type": "PlainText",
            "text": "Here are your ingredients."
          },
          "card": nil,
          "reprompt": nil,
          "shouldEndSession": true
        },
        "sessionAttributes": {}
      }
    end
    return response
  end


end
