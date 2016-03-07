require 'rails_helper'

RSpec.describe Request, type: :model do

  before(:all) do
    @user = create(:user)
    @launch_params = {
      "session": {
        "sessionId": "SessionId.26f49f30-55a2-4a56-857d-27f7d8782d1e",
        "application": {
          "applicationId": "amzn1.echo-sdk-ams.app.34e7d659-d6bc-471e-8ed7-f9fb8cb2f146"
        },
        "user": {
          "userId": "amazon_blahhh"
        },
        "new": true
      },
      "request": {
        "type": "LaunchRequest",
        "requestId": "EdwRequestId.749a4526-728b-45be-bf9b-a7bbcece8a86",
        "timestamp": "2016-03-07T17:36:51Z"
      }
    }.as_json
    @intent_params = {
      "session": {
        "sessionId": "SessionId.125eb41a-bee9-487f-8ced-17119994a951",
        "application": {
          "applicationId": "amzn1.echo-sdk-ams.app.34e7d659-d6bc-471e-8ed7-f9fb8cb2f146"
        },
        "user": {
          "userId": "amazon_blahhh"
        },
        "new": true
      },
      "request": {
        "type": "IntentRequest",
        "requestId": "EdwRequestId.3fb29ff6-3f44-417c-854e-9b18cc00577f",
        "timestamp": "2016-03-07T18:17:24Z",
        "intent": {
          "name": "RecipeList",
          "slots": {}
        }
      }
    }.as_json
  end


  describe "#new" do
    context "launch request" do
      it "creates a request object from params" do
        expect(Request.new(@launch_params)).to be_an_instance_of Request
      end
    end
    context "intent request" do
      it "creates a request object from params" do
        expect(Request.new(@intent_params)).to be_an_instance_of Request
      end
    end
  end

  describe "#route" do
    context "launch request" do
      it "returns a response" do
        req = Request.new(@launch_params)
        expect(req.route).to be_an_instance_of Response
      end
    end
    context "intent request" do
      it "returns a response" do
        req = Request.new(@intent_params)
        expect(req.route).to be_an_instance_of Response
      end
    end
  end


end
