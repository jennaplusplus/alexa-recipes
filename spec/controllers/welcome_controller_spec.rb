require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do

  describe "#index" do
    it "renders the index view" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "#ask" do
    let(:launch_params) do
      {
        "session": {
          "user": {
            "userId": "new_id"
          },
        },
        "request": {
          "type": "LaunchRequest",
        }
      }.as_json
    end

    it "renders json" do
      post :ask, launch_params
      expect(response.response_code).to eq 200
    end
  end

end
