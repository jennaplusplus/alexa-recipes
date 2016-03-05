require 'rails_helper'

RSpec.describe Recipe, type: :model do
  before(:all) do
    @recipe = create(:recipe)
  end

  describe "#format_ingredient" do
    it "returns string whether or not there is a unit" do
      expect(@recipe.format_ingredient({"name"=>"butter", "measurement"=>"1/2", "unit"=>"cup"})).to be_a String
      expect(@recipe.format_ingredient({"name"=>"egg", "measurement"=>"1"})).to be_a String
    end
  end

  describe "#number_of_steps" do
    it "returns the number of steps" do
      expect(@recipe.number_of_steps).to be_an Integer
    end
  end

  describe "#name" do
    it "returns the recipe name" do
      expect(@recipe.name).to be_a String
    end
  end

  describe "#steps" do
    it "returns the recipe steps" do
      expect(@recipe.steps).to be_an Array
    end
  end

  describe "#ingredients" do
    it "returns the recipe ingredients" do
      expect(@recipe.ingredients).to be_an Array
    end
  end

  describe "#cook_time" do
    it "returns the cook time when available" do
      expect(@recipe.cook_time).to be_a String
    end
    it "does not require cook time" do
      expect(build(:recipe, cook_time: nil)).to be_valid
    end
  end

  describe "#prep_time" do
    it "returns the prep time when available" do
      expect(@recipe.prep_time).to be_a String
    end
    it "does not require prep time" do
      expect(build(:recipe, prep_time: nil)).to be_valid
    end
  end

  describe "#servings" do
    it "returns the servings when available" do
      expect(@recipe.servings).to be_an Integer
    end
    it "does not require servings" do
      expect(build(:recipe, servings: nil)).to be_valid
    end
  end

  describe "#description" do
    it "returns the description when available" do
      expect(@recipe.description).to be_an String
    end
    it "does not require description" do
      expect(build(:recipe, description: nil)).to be_valid
    end
  end

  describe "#notes" do
    it "returns the notes when available" do
      expect(@recipe.notes).to be_an String
    end
    it "does not require notes" do
      expect(build(:recipe, notes: nil)).to be_valid
    end
  end

  describe "#advance_step" do
    it "increases the current step by 1" do
      expect{@recipe.advance_step}.to change{@recipe.current_step}.by(1)
    end
  end

  describe "#revert_step" do
    it "decreases the current step by 1" do
      expect{@recipe.revert_step}.to change{@recipe.current_step}.by(-1)
    end
  end

  describe "#reset_step" do
    it "sets the current step to 1" do
      @recipe.reset_step
      expect(@recipe.current_step).to eq 1
    end
  end

  describe "#go_to_step(number)" do
    it "goes to the given step" do
      @recipe.go_to_step(3)
      expect(@recipe.current_step).to eq 3
    end
  end


end
