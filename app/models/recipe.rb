class Recipe
  include Mongoid::Document
  field :name, type: String

  def self.build_response(text)
    response = {
      "version": "0.1.1",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": text
        },
        "card": nil,
        "reprompt": nil,
        "shouldEndSession": true
      },
      "sessionAttributes": {}
    }
    return response
  end

  def self.router(params)
    if params["request"]["type"] == "LaunchRequest"
      self.launch
    elsif params["request"]["type"] == "IntentRequest"
      self.intents(params)
    end
  end

  def self.launch
    response = {
      "version": "0.1.1",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": "Welcome to Recipes! Would you like a list of ingredients?"
        },
        "card": nil,
        "reprompt": nil,
        "shouldEndSession": false
      },
      "sessionAttributes": {"question": "list of ingredients"}
    }
    return response
  end

  def self.intents(params)
    if params["request"]["intent"]["name"] == "AMAZON.YesIntent"
      if params["session"]["attributes"]["question"] == "list of ingredients"
        Recipe.ingredient_list
      end
    elsif params["request"]["intent"]["name"] == "AMAZON.NoIntent"
      return Recipe.build_response("Ok.")
    elsif params["request"]["intent"]["name"] == "IngredientList"
      Recipe.ingredient_list
    end
  end

  def self.ingredient_list
    return Recipe.build_response("Here are your ingredients.")
  end


  # def self.begin(params)
  #   if params["request"]["type"] == "LaunchRequest"
  #     response = {
  #       "version": "0.1.1",
  #       "response": {
  #         "outputSpeech": {
  #           "type": "PlainText",
  #           "text": "Welcome to Recipes! Would you like a list of ingredients?"
  #         },
  #         "card": nil,
  #         "reprompt": nil,
  #         "shouldEndSession": false
  #       },
  #       "sessionAttributes": {"question": "list of ingredients"}
  #     }
  #     return response
  #   elsif params["request"]["type"] == "IntentRequest"
  #     if params["request"]["intent"]["name"] == "AMAZON.YesIntent"
  #       if params["session"]["attributes"]["question"] == "list of ingredients"
  #         Recipe.ingredient_list
  #       end
  #     elsif params["request"]["intent"]["name"] == "AMAZON.NoIntent"
  #       return Recipe.build_response("Ok.")
  #     elsif params["request"]["intent"]["name"] == "IngredientList"
  #       Recipe.ingredient_list
  #     end
  #   end
  # end



end
