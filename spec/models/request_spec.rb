require 'rails_helper'

RSpec.describe Request, type: :model do

  describe "#new" do
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

    let(:intent_params) do
      {
        "session": {
          "user": {
            "userId": "new_id"
          },
        },
        "request": {
          "type": "IntentRequest",
          "intent": {
            "name": "RecipeList",
            "slots": {}
          }
        }
      }.as_json
    end
    context "launch request" do
      it "creates a request object from params" do
        expect(Request.new(launch_params)).to be_an_instance_of Request
      end
    end
    context "intent request" do
      it "creates a request object from params" do
        expect(Request.new(intent_params)).to be_an_instance_of Request
      end
    end
  end

  describe "#route" do
    let(:user) do
       create(:user)
    end

    let(:launch_params) do
      {
        "session": {
          "user": {
            "userId": user.amazon_id
          },
        },
        "request": {
          "type": "LaunchRequest",
        }
      }.as_json
    end

    let(:intent_params) do
      {
        "session": {
          "user": {
            "userId": user.amazon_id
          },
        },
        "request": {
          "type": "IntentRequest",
          "intent": {
            "name": "RecipeList",
            "slots": {}
          }
        }
      }.as_json
    end
    context "launch request" do
      it "returns a response" do
        req = Request.new(launch_params)
        expect(req.route).to be_an_instance_of Response
      end
    end
    context "intent request" do
      it "returns a response" do
        req = Request.new(intent_params)
        expect(req.route).to be_an_instance_of Response
      end
    end
  end

  describe "#recipe_list" do
    let(:user) do
      create(:user)
    end

    let(:intent_params) do
      {
        "session": {
          "user": {
            "userId": user.amazon_id
          },
        },
        "request": {
          "type": "IntentRequest",
          "intent": {
            "name": "RecipeList",
            "slots": {}
          }
        }
      }.as_json
    end

    context "the user has no recipes" do
      it "returns a response" do
        req = Request.new(intent_params)
        expect(req.user.recipes.count).to eq 0
        expect(req.route).to be_an_instance_of Response
      end
    end
    context "the user has one recipe" do
      it "returns a response" do
        req = Request.new(intent_params)
        Recipe.create(user_id: req.user.id)
        expect(req.user.recipes.count).to eq 1
        expect(req.recipe_list).to be_an_instance_of Response
      end
    end
    context "the user has multiple recipes" do
      it "returns a response" do
        req = Request.new(intent_params)
        create(:recipe, user_id: req.user.id)
        create(:recipe, user_id: req.user.id)
        expect(req.user.recipes.count).to eq 2
        expect(req.recipe_list).to be_an_instance_of Response
      end
    end
  end

  describe "#get_ingredient" do
    let(:recipe) do
      create(:recipe)
    end

    let(:one_match_params) do
      {
        "session": {
          "user": {
            "userId": recipe.user.amazon_id
          },
        },
        "request": {
          "type": "IntentRequest",
          "intent": {
            "name": "GetIngredient",
            "slots": {
              "Ingredient": {
                "name": "Ingredient",
                "value": "salt"
              }
            }
          }
        }
      }.as_json
    end

    let(:two_match_params) do
      {
        "session": {
          "user": {
            "userId": recipe.user.amazon_id
          },
        },
        "request": {
          "type": "IntentRequest",
          "intent": {
            "name": "GetIngredient",
            "slots": {
              "Ingredient": {
                "name": "Ingredient",
                "value": "butter"
              }
            }
          }
        }
      }.as_json
    end

    let(:three_match_params) do
      {
        "session": {
          "user": {
            "userId": recipe.user.amazon_id
          },
        },
        "request": {
          "type": "IntentRequest",
          "intent": {
            "name": "GetIngredient",
            "slots": {
              "Ingredient": {
                "name": "Ingredient",
                "value": "chocolate"
              }
            }
          }
        }
      }.as_json
    end

    let(:bad_intent_params) do
      {
        "session": {
          "user": {
            "userId": recipe.user.amazon_id
          },
        },
        "request": {
          "type": "IntentRequest",
          "intent": {
            "name": "GetIngredient",
            "slots": {
              "Ingredient": {
                "name": "Ingredient"
              }
            }
          }
        }
      }.as_json
    end

    context "one matched ingredient" do
      it "returns a response" do
        req = Request.new(one_match_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.get_ingredient).to be_an_instance_of Response
      end
    end
    context "two matched ingredients" do
      it "returns a response" do
        req = Request.new(two_match_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.get_ingredient).to be_an_instance_of Response
      end
    end
    context "more than two matched ingredients" do
      it "returns a response" do
        req = Request.new(three_match_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.get_ingredient).to be_an_instance_of Response
      end
    end
    context "the ingredient was not understood" do
      it "returns a response" do
        req = Request.new(bad_intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.get_ingredient).to be_an_instance_of Response
      end
    end
  end

  describe "#ingredient_list" do
    let(:recipe) do
      create(:recipe)
    end

    let(:intent_params) do
      {
        "session": {
          "user": {
            "userId": recipe.user.amazon_id
          },
        },
        "request": {
          "type": "IntentRequest",
          "intent": {
            "name": "IngredientList",
            "slots": {}
          }
        }
      }.as_json
    end

    it "returns a response" do
      req = Request.new(intent_params)
      req.user["active_recipe_id"] = recipe.id
      expect(req.ingredient_list).to be_an_instance_of Response
    end
  end


end
