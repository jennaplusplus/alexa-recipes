class Recipe
  include Mongoid::Document
  field :name, type: String

  def self.launch
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
    return response
  end


end
