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
  before_validation :remove_empty_ingredients
  before_validation :strip_steps_and_ingredients
  before_validation :titleize_and_strip_name
  before_validation :replace_empty_strings_with_nil

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user }
  validates :steps, presence: true
  validates :ingredients, presence: true
  validates_with IngredientValidator

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
    if !self.steps.nil?
      self.steps.each do |step|
        self.steps.delete(step) if !step.present?
      end
    end
  end

  def remove_empty_ingredients
    if !self.ingredients.nil?
      self.ingredients.each do |ingredient|
        if !ingredient["name"].present? && !ingredient["measurement"].present? && !ingredient["unit"].present?
          self.ingredients.delete(ingredient)
        end
        ingredient["measurement"] = nil if ingredient["measurement"] == ""
        ingredient["unit"] = nil if ingredient["unit"] == ""
      end
    end
  end

  def titleize_and_strip_name
    self.name = self.name.titleize if self.name.present?
    self.name.strip! if self.name.present?
  end

  def strip_steps_and_ingredients
    if !self.steps.nil?
      self.steps.each do |step|
        step.strip!
      end
    end

    if !self.ingredients.nil?
      self.ingredients.each do |ingredient|
        ingredient["name"].strip! if ingredient["name"]
        ingredient["measurement"].strip! if ingredient["measurement"]
        ingredient["unit"].strip! if ingredient["unit"]
      end
    end
  end

  def replace_empty_strings_with_nil
    fields = [self.name, self.description, self.prep_time, self.cook_time, self.servings, self.notes]
    fields.each { |field| field.strip! if field.present? }
    fields.map! { |field| field == "" ? nil : field }
  end

end
