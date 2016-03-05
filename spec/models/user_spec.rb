require 'rails_helper'

RSpec.describe User, type: :model do

  describe "#active_recipe" do

    before(:each) do
      @recipe = create(:recipe)
      @user = @recipe.user
    end

    it "returns nil if no recipe is active" do
      expect(@user.active_recipe).to be_nil
    end

    it "returns a recipe if one is specified" do
      @user["active_recipe_id"] = @recipe.id
      expect(@user.active_recipe).to be_an_instance_of Recipe
    end
  end


end
