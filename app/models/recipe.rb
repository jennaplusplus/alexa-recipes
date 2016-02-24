class Recipe
  include Mongoid::Document
  field :name, type: String

  def format_ingredient(ingredient_hash)
    if ingredient_hash["unit"].nil?
      "#{ingredient_hash["measurement"]} #{ingredient_hash["name"]} "
    else
      "#{ingredient_hash["measurement"]} #{ingredient_hash["unit"]} of #{ingredient_hash["name"]} "
    end
  end

end
