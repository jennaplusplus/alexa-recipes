class Recipe
  include Mongoid::Document
  field :name, type: String

  def format_ingredient(ingredient_hash)
    if ingredient_hash["unit"].nil?
      "#{ingredient_hash["measurement"]} #{ingredient_hash["name"]}"
    else
      "#{ingredient_hash["measurement"]} #{ingredient_hash["unit"]} of #{ingredient_hash["name"]}"
    end
  end

  def get_ingredient_hash(ingredient_name)
    self["ingredients"].detect { |ingredient| ingredient["name"] == ingredient_name }
  end

  def number_of_steps
    self["steps"].length
  end

  ["steps", "ingredients"].each do |attribute|
    define_method(attribute.to_sym) do 
      self[attribute]
    end
  end

  #
  # def steps
  #   self["steps"]
  # end

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
