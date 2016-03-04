require 'rails_helper'

RSpec.describe Recipe, type: :model do

  describe "a recipe document" do
    it "is valid" do
      expect(create(:recipe)).to be_valid
    end
  end
end
