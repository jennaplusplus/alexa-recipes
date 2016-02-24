class Recipe
  include Mongoid::Document
  field :name, type: String

  # def self.router(params)
  #   if params["request"]["type"] == "LaunchRequest"
  #     self.launch
  #   elsif params["request"]["type"] == "IntentRequest"
  #     self.intents(params)
  #   end
  # end

  # def self.launch
  #   Recipe.build_response({
  #     text: "Welcome to Recipes! Would you like a list of ingredients?",
  #     shouldEndSession: false,
  #     sessionAttributes: {"question": "list of ingredients"}
  #   })
  # end

  def self.intents(params)
    if params["request"]["intent"]["name"] == "AMAZON.YesIntent"
      if params["session"]["attributes"]["question"] == "list of ingredients"
        Recipe.ingredient_list
      end
    elsif params["request"]["intent"]["name"] == "AMAZON.NoIntent"
      Recipe.build_response({
        text: "Ok.",
        shouldEndSession: true
      })
    elsif params["request"]["intent"]["name"] == "IngredientList"
      Recipe.ingredient_list
    elsif params["request"]["intent"]["name"] == "IngredientAmount"
      Recipe.ingredient_amount(params)
    elsif params["request"]["intent"]["name"] == "IngredientNeeded"
      Recipe.ingredient_amount(params)
    end
  end

  def self.ingredient_list
    recipe = Recipe.first
    list = "Here are the ingredients for #{recipe["name"]}. "
    recipe["ingredients"].each do |ingredient|
      if ingredient["unit"].nil?
        list += "#{ingredient["measurement"]} #{ingredient["name"]}, "
      else
        list += "#{ingredient["measurement"]} #{ingredient["unit"]} of #{ingredient["name"]}, "
      end
    end
    list += "."
    Recipe.build_response({
      text: list,
      shouldEndSession: true
    })
  end

  def self.ingredient_amount(params)
    query = params["request"]["intent"]["slots"]["Ingredient"]["value"]
    recipe = Recipe.first # this will change to look up the current user's active recipe
    ingredient_names = recipe["ingredients"].map { |i| i["name"] }
    if ingredient_names.include?(query)
      ing = recipe["ingredients"].detect { |ingredient| ingredient["name"] == query }
      if ing["unit"].nil?
        Recipe.build_response({
          text: "You need #{ing["measurement"]} #{ing["name"]}. ",
          shouldEndSession: true
        })
      else
        Recipe.build_response({
          text: "You need #{ing["measurement"]} #{ing["unit"]} of #{ing["name"]}. ",
          shouldEndSession: true
        })
      end
    else
      Recipe.build_response({
        text: "I couldn't find #{query} in this recipe.",
        shouldEndSession: true
      })
    end
  end
  #
  # def self.build_response(info_hash)
  #   response = {
  #     "version": "0.1.1",
  #     "response": {
  #       "outputSpeech": {
  #         "type": "PlainText",
  #         "text": info_hash[:text]
  #       },
  #       "card": nil,
  #       "reprompt": nil,
  #       "shouldEndSession": info_hash[:shouldEndSession]
  #     },
  #     "sessionAttributes": info_hash[:sessionAttributes]
  #   }
  #   return response
  # end

end
