class Recipe
  include Mongoid::Document
  field :name, type: String

  def format_ingredient(ingredient_hash)
    if ingredient_hash["unit"].nil?
      "#{ingredient["measurement"]} #{ingredient["name"]} "
    else
      "#{ingredient["measurement"]} #{ingredient["unit"]} of #{ingredient["name"]} "
    end
  end

end
