class Recipe
  include Mongoid::Document
  belongs_to :user

  field :name, type: String
  field :description, type: String
  field :notes, type: String
  field :cook_time, type: String
  field :prep_time, type: String
  field :servings, type: Integer
  field :current_step, type: Integer
  field :ingredients, type: Array
  field :steps, type: Array

  def format_ingredient(ingredient_hash)
    if ingredient_hash["unit"].nil?
      "#{ingredient_hash["measurement"]} #{ingredient_hash["name"]}"
    else
      "#{ingredient_hash["measurement"]} #{ingredient_hash["unit"]} of #{ingredient_hash["name"]}"
    end
  end

  def number_of_steps
    self["steps"].length
  end

  ["name", "steps", "ingredients", "cook_time", "prep_time", "servings", "description", "notes"].each do |attribute|
    define_method(attribute.to_sym) do
      self[attribute]
    end
  end

  def advance_step
    self["current_step"] += 1
    self.save
  end

  def revert_step
    self["current_step"] -= 1
    self.save
  end

  def reset_step
    self["current_step"] = 1
    self.save
  end

  def go_to_step(number)
    self["current_step"] = number.to_i
    self.save
  end

end
