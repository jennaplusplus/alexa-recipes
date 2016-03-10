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

  before_validation :remove_empty_steps
  before_validation :remove_nameless_ingredients

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

  ["name", "steps", "current_step", "ingredients", "cook_time", "prep_time", "servings", "description", "notes"].each do |attribute|
    define_method(attribute.to_sym) do
      self[attribute]
    end
  end

  def advance_step
    if self["current_step"] < self.steps.length
      self["current_step"] += 1
      self.save
    end
  end

  def revert_step
    if self["current_step"] > 1
      self["current_step"] -= 1
      self.save
    end
  end

  def reset_step
    self["current_step"] = 1
    self.save
  end

  def go_to_step(number)
    if number.to_i > 0 && number.to_i <= self.steps.length
      self["current_step"] = number.to_i
      self.save
    end
  end

  protected
  def remove_empty_steps
    (0...self.steps.length).each do |i|
      self.steps.delete_at(i) if !self.steps[i].present?
    end
  end

  def remove_nameless_ingredients
    (0...self.ingredients.length).each do |i|
      if !self.ingredients[i].present? || !self.ingredients[i]["name"].present?
        self.ingredients.delete_at(i)
      end
    end
  end

end
