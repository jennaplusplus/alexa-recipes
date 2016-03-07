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
        expect(req.recipe_list).to be_an_instance_of Response
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

  describe "#get_current_step" do
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
            "name": "GetCurrentStep",
            "slots": {}
          }
        }
      }.as_json
    end

    it "returns a response" do
      req = Request.new(intent_params)
      req.user["active_recipe_id"] = recipe.id
      expect(req.get_current_step).to be_an_instance_of Response
    end
  end

  describe "#advance_step" do
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
            "name": "GetNextStep",
            "slots": {}
          }
        }
      }.as_json
    end

    context "user hasn't finished the recipe" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.get_next_step).to be_an_instance_of Response
      end
    end
    context "user has finished the recipe" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:current_step, recipe.number_of_steps)
        expect(req.get_next_step).to be_an_instance_of Response
      end
    end
  end

  describe "#get_previous_step" do
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
            "name": "GetPreviousStep",
            "slots": {}
          }
        }
      }.as_json
    end

    context "user is past the first step" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.get_previous_step).to be_an_instance_of Response
      end
    end
    context "user is already on the first step" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:current_step, 1)
        expect(req.get_previous_step).to be_an_instance_of Response
      end
    end

  end

  describe "#reset_step" do
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
            "name": "ResetStep",
            "slots": {}
          }
        }
      }.as_json
    end

    it "sets the current step to 1" do
      req = Request.new(intent_params)
      req.user["active_recipe_id"] = recipe.id
      req.reset_step
      expect(req.user.active_recipe.current_step).to eq 1
    end
    it "returns a response" do
      req = Request.new(intent_params)
      req.user["active_recipe_id"] = recipe.id
      expect(req.get_next_step).to be_an_instance_of Response
    end
  end

  describe "#go_to_ordinal_step" do
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
            "name": "GoToOrdinalStep",
            "slots": {
              "OrdinalNumber": {
                "name": "OrdinalNumber",
                "value": "fourth"
              }
            }
          }
        }
      }.as_json
    end
    context "query is not within available bounds" do
      it "maintains the current step" do
        intent_params["request"]["intent"]["slots"]["OrdinalNumber"]["value"] = "50th"
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        current_step = req.user.active_recipe.current_step
        req.go_to_ordinal_step
        expect(req.user.active_recipe.current_step).to eq current_step
      end
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.go_to_ordinal_step).to be_an_instance_of Response
      end
    end
    context "query is within available bounds" do
      it "updates the current step" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.go_to_ordinal_step
        expect(req.user.active_recipe.current_step).to eq 4
      end
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.go_to_ordinal_step).to be_an_instance_of Response
      end
    end
  end

  describe "#go_to_step" do
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
            "name": "GoToStep",
            "slots": {
              "Number": {
                "name": "Number",
                "value": "3"
              }
            }
          }
        }
      }.as_json
    end
    context "goes to the step if it's valid" do
      it "updates the current step" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.go_to_step
        expect(req.user.active_recipe.current_step).to eq 3
      end
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.go_to_step).to be_an_instance_of Response
      end
    end
    context "it does not go to the step if it's invalid" do
      it "maintains the current step" do
        intent_params["request"]["intent"]["slots"]["Number"]["value"] = "100"
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        current_step = req.user.active_recipe.current_step
        req.go_to_step
        expect(req.user.active_recipe.current_step).to eq current_step
      end
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.go_to_step).to be_an_instance_of Response
      end
    end
    context "desired step was not understood" do
      it "maintains the current step" do
        intent_params["request"]["intent"]["slots"]["Number"]["value"] = "?"
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        current_step = req.user.active_recipe.current_step
        req.go_to_step
        expect(req.user.active_recipe.current_step).to eq current_step
      end
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.go_to_step).to be_an_instance_of Response
      end
    end
  end

  describe "#go_to_final_step" do
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
            "name": "GoToFinalStep",
            "slots": {}
          }
        }
      }.as_json
    end

    it "sets the current step to the final one" do
      req = Request.new(intent_params)
      req.user["active_recipe_id"] = recipe.id
      req.go_to_final_step
      expect(req.user.active_recipe.current_step).to eq req.user.active_recipe.number_of_steps
    end
    it "returns a response" do
      req = Request.new(intent_params)
      req.user["active_recipe_id"] = recipe.id
      expect(req.go_to_final_step).to be_an_instance_of Response
    end
  end

  describe "#how_many_steps" do
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
            "name": "HowManySteps",
            "slots": {}
          }
        }
      }.as_json
    end

    it "returns a response" do
      req = Request.new(intent_params)
      req.user["active_recipe_id"] = recipe.id
      expect(req.how_many_steps).to be_an_instance_of Response
    end
  end

  describe "#how_many_steps_left" do
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
            "name": "HowManyStepsLeft",
            "slots": {}
          }
        }
      }.as_json
    end

    context "the user is on the final step" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:current_step, req.user.active_recipe.number_of_steps)
        req.user.active_recipe.save
        expect(req.how_many_steps_left).to be_an_instance_of Response
      end
    end
    context "the user has one more step" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:current_step, req.user.active_recipe.number_of_steps - 1)
        expect(req.how_many_steps_left).to be_an_instance_of Response
      end
    end
    context "the user has more than one step left" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:current_step, req.user.active_recipe.number_of_steps - 2)
        expect(req.how_many_steps_left).to be_an_instance_of Response
      end
    end
  end

  describe "#get_recipe_name" do
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
            "name": "GetRecipeName",
            "slots": {}
          }
        }
      }.as_json
    end

    it "returns a response" do
      req = Request.new(intent_params)
      req.user["active_recipe_id"] = recipe.id
      expect(req.get_recipe_name).to be_an_instance_of Response
    end
  end

  describe "#get_servings" do
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
            "name": "GetServings",
            "slots": {}
          }
        }
      }.as_json
    end

    context "the recipe makes 1 servings" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:servings, 1)
        expect(req.get_servings).to be_an_instance_of Response
      end
    end
    context "the recipe makes more than 1 serving" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:servings, 2)
        expect(req.get_servings).to be_an_instance_of Response
      end
    end
    context "no serving info" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:servings, nil)
        expect(req.get_servings).to be_an_instance_of Response
      end
    end
    context "weird serving info" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:servings, -5)
        expect(req.get_servings).to be_an_instance_of Response
      end
    end
  end

  describe "#get_prep_time" do
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
            "name": "GetPrepTime",
            "slots": {}
          }
        }
      }.as_json
    end

    context "prep time and cook time" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:prep_time, "10 minutes")
        req.user.active_recipe.update_attribute(:cook_time, "15 minutes")
        expect(req.get_prep_time).to be_an_instance_of Response
      end
    end
    context "just prep time" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:prep_time, "10 minutes")
        req.user.active_recipe.update_attribute(:cook_time, nil)
        expect(req.get_prep_time).to be_an_instance_of Response
      end
    end
    context "just cook time" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:prep_time, nil)
        req.user.active_recipe.update_attribute(:cook_time, "15 minutes")
        expect(req.get_prep_time).to be_an_instance_of Response
      end
    end
    context "no time info" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:prep_time, nil)
        req.user.active_recipe.update_attribute(:cook_time, nil)
        expect(req.get_prep_time).to be_an_instance_of Response
      end
    end
  end

  describe "#get_description" do
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
            "name": "GetDescription",
            "slots": {}
          }
        }
      }.as_json
    end

    context "the recipe has a description" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:description, "something")
        expect(req.get_description).to be_an_instance_of Response
      end
    end
    context "no description" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:description, nil)
        expect(req.get_description).to be_an_instance_of Response
      end
    end
  end

  describe "#get_notes" do
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
            "name": "GetNotes",
            "slots": {}
          }
        }
      }.as_json
    end

    context "the recipe has notes" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:notes, "something")
        expect(req.get_notes).to be_an_instance_of Response
      end
    end
    context "no notes" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:notes, nil)
        expect(req.get_notes).to be_an_instance_of Response
      end
    end
  end

  describe "#get_steps" do
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
            "name": "GetSteps",
            "slots": {}
          }
        }
      }.as_json
    end

    context "the recipe has steps" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.get_steps).to be_an_instance_of Response
      end
    end
    context "no steps" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:steps, nil)
        expect(req.get_steps).to be_an_instance_of Response
      end
    end
  end

  describe "#preview_recipe" do
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
            "name": "PreviewRecipe",
            "slots": {}
          }
        }
      }.as_json
    end

    context "recipe with lots of info" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.preview_recipe).to be_an_instance_of Response
      end
    end
    context "missing cook time" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:cook_time, nil)
        expect(req.preview_recipe).to be_an_instance_of Response
      end
    end
    context "missing prep time" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:prep_time, nil)
        expect(req.preview_recipe).to be_an_instance_of Response
      end
    end
    context "only 1 serving" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:servings, 1)
        expect(req.preview_recipe).to be_an_instance_of Response
      end
    end
    context "only 1 step" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        req.user.active_recipe.update_attribute(:steps, ["Do stuff"])
        expect(req.preview_recipe).to be_an_instance_of Response
      end
    end
  end

  describe "#bad_intent" do
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
            "name": "WeirdRandomIntent",
            "slots": {}
          }
        }
      }.as_json
    end
    context "intent in schema but not in code" do
      it "returns a response" do
        req = Request.new(intent_params)
        req.user["active_recipe_id"] = recipe.id
        expect(req.route).to be_an_instance_of Response
      end
    end
  end



end
