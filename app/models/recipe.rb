class Recipe
  include Mongoid::Document
  field :name, type: String

  # def self.ingredient_amount(params)
  #   query = params["request"]["intent"]["slots"]["Ingredient"]["value"]
  #   recipe = Recipe.first # this will change to look up the current user's active recipe
  #   ingredient_names = recipe["ingredients"].map { |i| i["name"] }
  #   if ingredient_names.include?(query)
  #     ing = recipe["ingredients"].detect { |ingredient| ingredient["name"] == query }
  #     if ing["unit"].nil?
  #       Recipe.build_response({
  #         text: "You need #{ing["measurement"]} #{ing["name"]}. ",
  #         shouldEndSession: true
  #       })
  #     else
  #       Recipe.build_response({
  #         text: "You need #{ing["measurement"]} #{ing["unit"]} of #{ing["name"]}. ",
  #         shouldEndSession: true
  #       })
  #     end
  #   else
  #     Recipe.build_response({
  #       text: "I couldn't find #{query} in this recipe.",
  #       shouldEndSession: true
  #     })
  #   end
  # end

end
