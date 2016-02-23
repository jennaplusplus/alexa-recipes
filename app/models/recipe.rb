class Recipe
  include Mongoid::Document
  field :name, type: String

  def self.router(params)
    if params["request"]["type"] == "LaunchRequest"
      self.launch
    elsif params["request"]["type"] == "IntentRequest"
      self.intents(params)
    end
  end

  def self.launch
    Recipe.build_response({text: "Welcome to Recipes! Would you like a list of ingredients?", shouldEndSession: false})
  end

  def self.intents(params)
    if params["request"]["intent"]["name"] == "AMAZON.YesIntent"
      if params["session"]["attributes"]["question"] == "list of ingredients"
        Recipe.ingredient_list
      end
    elsif params["request"]["intent"]["name"] == "AMAZON.NoIntent"
      Recipe.build_response({text: "Ok.", shouldEndSession: true})
    elsif params["request"]["intent"]["name"] == "IngredientList"
      Recipe.ingredient_list
    end
  end

  def self.ingredient_list
    recipe = Recipe.first
    list = "Here are the ingredients for #{recipe["name"]}. "
    recipe["ingredients"].each do |ingredient|
      list += "#{ingredient["name"]}, "
    end
    Recipe.build_response({text: list, shouldEndSession: true})
  end

  def self.build_response(info_hash)
    response = {
      "version": "0.1.1",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": info_hash[:text]
        },
        "card": nil,
        "reprompt": nil,
        "shouldEndSession": info_hash[:shouldEndSession]
      },
      "sessionAttributes": info_hash[:sessionAttributes]
    }
    return response
  end
end
