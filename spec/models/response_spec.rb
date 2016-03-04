require 'rails_helper'

RSpec.describe Response, type: :model do
  before :each do
    @response = Response.new({})
  end

  describe "#new" do
    it "returns a Response object" do
      expect(@response).to be_an_instance_of Response
    end
  end
end
