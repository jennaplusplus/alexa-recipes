require 'rails_helper'

RSpec.describe Response, type: :model do

  describe "#new" do
    it "returns a Response object" do
      response = Response.new({})
      expect(response).to be_an_instance_of Response
    end
  end
end
