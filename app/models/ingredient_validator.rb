class IngredientValidator < ActiveModel::Validator
  def validate(record)
    record.ingredients.each do |ingredient|
      if !ingredient["name"].present?
        record.errors[:ingredient] << "name can't be blank"
      elsif ingredient["unit"].present? && !ingredient["measurement"].present?
        record.errors[:ingredient] << "measurement can't be blank when unit is provided"
      end
    end
  end
end
