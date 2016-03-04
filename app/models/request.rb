class Request
  attr_reader :data, :type, :session, :intent, :slots, :user

  def initialize(params)
    @data = params
    @type = params["request"]["type"]
    @session = params["session"]
    if params["request"]["intent"]
      @intent = params["request"]["intent"]["name"]
      @slots = params["request"]["intent"]["slots"]
    end
    @user = User.find_by(amazon_id: params["session"]["user"]["userId"])
  end

  def route
    if @type == "LaunchRequest"
      self.launch
    elsif @type == "IntentRequest"
      self.intent
    end
  end

  def launch
    Response.new({
      text: "Welcome to Recipes!",
      shouldEndSession: true
    })
  end

  METHODS = {
    "IngredientList"    => :ingredient_list,
    "GetIngredient"     => :get_ingredient,
    "GetCurrentStep"    => :get_current_step,
    "GetNextStep"       => :get_next_step,
    "ResetStep"         => :reset_step,
    "GoToStep"          => :go_to_step,
    "GoToOrdinalStep"   => :go_to_ordinal_step,
    "HowManySteps"      => :how_many_steps,
    "GetPreviousStep"   => :get_previous_step,
    "GoToFinalStep"     => :go_to_final_step,
    "HowManyStepsLeft"  => :how_many_steps_left,
    "GetRecipeName"     => :get_recipe_name,
    "GoToRecipe"        => :go_to_recipe,
    "SayRecipeName"     => :go_to_recipe,
    "RecipeList"        => :recipe_list,
    "GetServings"       => :get_servings,
    "GetPrepTime"       => :get_prep_time,
    "GetDescription"    => :get_description,
    "GetNotes"          => :get_notes,
    "GetSteps"          => :get_steps,
    "PreviewRecipe"     => :preview_recipe
  }

  MAPPINGS = {
    "1st" => 1,
    "2nd" => 2,
    "3rd" => 3,
    "4th" => 4,
    "5th" => 5,
    "6th" => 6,
    "7th" => 7,
    "8th" => 8,
    "9th" => 9,
    "10th" => 10,
    "11th" => 11,
    "12th" => 12,
    "13th" => 13,
    "14th" => 14,
    "15th" => 15,
    "16th" => 16,
    "17th" => 17,
    "18th" => 18,
    "19th" => 19,
    "20th" => 20,
    "21st" => 21,
    "22nd" => 22,
    "23rd" => 23,
    "24th" => 24,
    "25th" => 25,
    "26th" => 26,
    "27th" => 27,
    "28th" => 28,
    "29th" => 29,
    "30th" => 30,
    "second" => 2,
    "third" => 3,
    "fourth" => 4,
    "fifth" => 5,
    "sixth" => 6,
    "seventh" => 7,
    "eighth" => 8,
    "ninth" => 9,
    "tenth" => 10,
    "eleventh" => 11,
    "twelfth" => 12,
    "thirteenth" => 13,
    "fourteenth" => 14,
    "fifteenth" => 15,
    "sixteenth" => 16,
    "seventeenth" => 17,
    "eighteenth" => 18,
    "nineteenth" => 19,
    "twentieth" => 20,
  }

  def intent
    if @intent == "AMAZON.YesIntent"
      if @session["attributes"] && @session["attributes"]["question"] == "list of ingredients"
        self.ingredient_list
      elsif @session["attributes"] && @session["attributes"]["question"] == "list of recipes"
        self.recipe_list
      elsif @session["attributes"] && @session["attributes"]["question"] == "want this recipe"
        selection = Recipe.find(@session["attributes"]["recipe_id"])
        @user["active_recipe_id"] = selection.id
        @user.save
        return Response.new({
          text: "I found your recipe for #{selection["name"]}. Would you like a list of ingredients?",
          shouldEndSession: false,
          sessionAttributes: { "question" => "list of ingredients" }
        })
      else
        return Response.new({
          text: "I don't understand the question and I won't respond to it.",
          shouldEndSession: true
        })
      end
    elsif @intent == "AMAZON.NoIntent"
      Response.new({
        text: "Ok.",
        shouldEndSession: true
      })
    elsif METHODS[@intent]
      if @intent != "GoToRecipe" && @intent != "RecipeList" && @user.active_recipe.nil?
        if @session["attributes"]
          self.go_to_recipe
        else
          return Response.new({
            text: "Sorry, you don't have an open recipe. Which recipe would you like to open?",
            shouldEndSession: false,
            sessionAttributes: {"question" => "which recipe"}
          })
        end
      else
        self.send(METHODS[@intent])
      end
    else
      self.bad_intent
    end
  end

  def recipe_list
    recipes = @user.recipes
    if recipes.length == 0
      text = "You don't have any saved recipes. Add some on alexa recipes dot com!"
    elsif recipes.length == 1
      text = "You have 1 saved recipe. #{recipes[0].name} ."
    else
      text = "You have #{recipes.length} available recipes. "
      recipes.each do |recipe|
        text += recipe["name"] + ", "
      end
      text += "."
    end
    Response.new({
      text: text,
      shouldEndSession: true
    })
  end

  def go_to_recipe
    recipes = @user.recipes
    target_recipe = @slots["Recipe"]["value"]
    if target_recipe.nil?
      return Response.new({
        text: "Sorry, I didn't understand which recipe you asked for.",
        shouldEndSession: true
      })
    elsif recipes.empty?
      return Response.new({
        text: "You don't have any saved recipes. Add some on alexa recipes dot com!",
        shouldEndSession: true
      })
    end
    distances = recipes.get_pair_distances(target_recipe.downcase)
    ranked = distances.keys.sort_by { |key| distances[key] }.reverse! # array of recipe documents sorted from best to worst match
    if distances[ranked[0]] >= 0.9
      selection = ranked[0]
      @user["active_recipe_id"] = selection.id
      @user.save
      return Response.new({
        text: "I found your recipe for #{selection["name"]}. Would you like a list of ingredients?",
        shouldEndSession: false,
        sessionAttributes: { "question" => "list of ingredients" }
      })
    elsif distances[ranked[0]] < 0.3
      Response.new({
        text: "None of your saved recipes matched your request. Would you like to hear a list of your saved recipes?",
        shouldEndSession: false,
        sessionAttributes: { "question" => "list of recipes" }
      })
    else
      possibilities = []
      i = 0
      while distances[ranked[i]] >= 0.3
        possibilities.push(ranked[i])
        i += 1
      end
      if possibilities.length == 1
        return Response.new({
          text: "Is this the recipe you wanted? #{possibilities[0]["name"]}",
          shouldEndSession: false,
          sessionAttributes: { "question" => "want this recipe", "recipe_id" => possibilities[0].id }
        })
      else
        list_of_names = ""
        possibilities.each do |recipe|
          list_of_names += "#{recipe["name"]}, "
        end
        return Response.new({
          text: "Which of these recipes did you mean? #{list_of_names}.",
          shouldEndSession: false,
          sessionAttributes: { "question" => "which recipe" }
        })
      end
    end
  end

  def ingredient_list
    recipe = @user.active_recipe
    list = "Here are the ingredients for #{recipe["name"]}. "
    recipe["ingredients"].each do |ingredient|
      list += recipe.format_ingredient(ingredient) + ", "
    end
    list += "."
    Response.new({
      text: list,
      shouldEndSession: true
    })
  end

  def get_ingredient
    query = @slots["Ingredient"]["value"]
    recipe = @user.active_recipe

    if !query.nil?
      query_set = Set.new
      query.split.each do |word|
        query_set.add(word)
        query_set.add(word.singularize)
        query_set.add(word.pluralize)
      end

      matches = recipe["ingredients"].select do |ingredient|
        query_set.any? { |word| ingredient["name"].include?(word)}
      end
    end

    if query.nil? || matches.length == 0
      response = "I couldn't find that in this recipe. "
      response += "Here are the ingredients for #{recipe["name"]}. "
      recipe["ingredients"].each do |ingredient|
        response += "#{recipe.format_ingredient(ingredient)}, "
      end
      response += "."
    elsif matches.length == 1
      response = "You need #{recipe.format_ingredient(matches[0])}. "
    elsif matches.length == 2
      response = "You need #{recipe.format_ingredient(matches[0])} and #{recipe.format_ingredient(matches[1])}. "
    elsif matches.length > 2
      response = "You need "
      matches[0..-2].each do |match|
        response += "#{recipe.format_ingredient(match)}, "
      end
      response += "and #{recipe.format_ingredient(matches[-1])}."
    end

    Response.new({
      text: response,
      shouldEndSession: true
    })
  end

  def get_current_step
    recipe = @user.active_recipe
    steps = recipe.steps
    Response.new({
      text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"] - 1]}",
      shouldEndSession: true
    })
  end

  def get_next_step
    recipe = @user.active_recipe
    steps = recipe.steps
    recipe.advance_step
    if recipe["current_step"] > recipe.number_of_steps
      recipe.revert_step
      Response.new({
        text: "You've finished this recipe. Enjoy!",
        shouldEndSession: true
      })
    else
      Response.new({
        text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"] - 1]}",
        shouldEndSession: true
      })
    end
  end

  def reset_step
    recipe = @user.active_recipe
    steps = recipe.steps
    recipe.reset_step
    Response.new({
      text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"] - 1]}",
      shouldEndSession: true
    })
  end

  def go_to_ordinal_step
    query = @slots["OrdinalNumber"]["value"]
    if MAPPINGS[query].nil?
      ordinal_slot = "out of bounds"
    else
      ordinal_slot = MAPPINGS[query]
    end
    self.go_to_step(ordinal_slot)
  end

  def go_to_step(ordinal_slot=nil)
    if ordinal_slot == "out of bounds"
      query = nil
    elsif ordinal_slot
      query = ordinal_slot
    else
      query = @slots["Number"]["value"]
    end
    recipe = @user.active_recipe
    steps = recipe.steps
    if !query.nil? && query.to_i > 0 && query.to_i <= recipe.number_of_steps
      recipe.go_to_step(query)
      Response.new({
        text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"] - 1]}",
        shouldEndSession: true
      })
    elsif query.to_i < 1 || query.to_i > recipe.number_of_steps
      Response.new({
        text: "For this recipe, you can ask for a step between 1 and #{recipe.number_of_steps}.",
        shouldEndSession: true
      })
    else
      Response.new({
        text: "Sorry, I didn't understand.",
        shouldEndSession: true
      })
    end
  end

  def go_to_final_step
    recipe = @user.active_recipe
    steps = recipe.steps
    recipe.go_to_step(recipe.number_of_steps)
    Response.new({
      text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"] - 1]}",
      shouldEndSession: true
    })
  end

  def how_many_steps
    recipe = @user.active_recipe
    Response.new({
      text: "This recipe has #{recipe.number_of_steps} steps.",
      shouldEndSession: true
    })
  end

  def get_previous_step
    recipe = @user.active_recipe
    steps = recipe.steps
    recipe.revert_step
    if recipe["current_step"] < 1
      recipe.advance_step
      Response.new({
        text: "You're already on the first step.",
        shouldEndSession: true
      })
    else
      Response.new({
        text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"] - 1]}",
        shouldEndSession: true
      })
    end
  end

  def how_many_steps_left
    recipe = @user.active_recipe
    left = recipe.number_of_steps - recipe["current_step"]
    if left == 0
      text = "You're on the last step."
    elsif left == 1
      text = "After this step, there is one more step."
    else
      text = "After this step, there are #{left} steps left."
    end
    Response.new({
      text: text,
      shouldEndSession: true
    })
  end

  def get_recipe_name
    recipe = @user.active_recipe
    Response.new({
      text: "This is your recipe for #{recipe["name"]}.",
      shouldEndSession: true
    })
  end

  def get_servings
    recipe = @user.active_recipe
    if recipe.servings
      if recipe.servings == 1
        text = "This recipe makes 1 serving."
      elsif recipe.servings > 1
        text = "This recipe makes #{recipe.servings} servings."
      else
        text = "There is no serving information available for this recipe."
      end
    else
      text = "There is no serving information available for this recipe."
    end
    Response.new({
      text: text,
      shouldEndSession: true
    })
  end

  def get_prep_time
    recipe = @user.active_recipe
    if recipe.prep_time && recipe.cook_time
      text = "This recipe takes #{recipe.prep_time} to prepare and #{recipe.cook_time} to cook."
    elsif recipe.prep_time
      text = "This recipe takes #{recipe.prep_time} to prepare."
    elsif recipe.cook_time
      text = "This recipe takes #{recipe.cook_time} to cook."
    else
      text = "There is no preparation time or cook time available for this recipe."
    end
    Response.new({
      text: text,
      shouldEndSession: true
    })
  end

  def get_description
    recipe = @user.active_recipe
    if recipe.description
      text = "Here is the description. #{recipe.description}."
    else
      text = "There is no description for this recipe."
    end
    Response.new({
      text: text,
      shouldEndSession: true
    })
  end

  def get_notes
    recipe = @user.active_recipe
    if recipe.notes
      text = "Here are your notes. #{recipe.notes}."
    else
      text = "There are no notes for this recipe."
    end
    Response.new({
      text: text,
      shouldEndSession: true
    })
  end

  def get_steps
    recipe = @user.active_recipe
    if recipe.steps
      text = "Here's a list of all the steps for #{recipe.name}. "
      recipe.steps.each do |step|
        text += "#{step.sub(/\.*$/, "")} . "
      end
    else
      text = "There are no steps saved for this recipe."
    end
    Response.new({
      text: text,
      shouldEndSession: true
    })
  end

  def preview_recipe
    recipe = @user.active_recipe
    text = "Here's an overview for your recipe for #{recipe.name}. "

    if recipe.description
      text += "The recipe has the following description. #{recipe.description}. "
    end

    if recipe.prep_time && recipe.cook_time
      text += "This recipe takes #{recipe.prep_time} to prepare and #{recipe.cook_time} to cook. "
    elsif recipe.prep_time
      text += "This recipe takes #{recipe.prep_time} to prepare. "
    elsif recipe.cook_time
      text += "This recipe takes #{recipe.cook_time} to cook. "
    end

    if recipe.servings
      if recipe.servings == 1
        text += "The recipe makes 1 serving. "
      elsif recipe.servings > 1
        text += "The recipe makes #{recipe.servings} servings. "
      else
      end
    end

    if recipe.notes
      text += "The recipe has the following notes. #{recipe.notes}. "
    end

    list = "The recipe has the following ingredients. "
    recipe.ingredients.each do |ingredient|
      list += recipe.format_ingredient(ingredient) + ", "
    end
    list += ". "
    text += list

    if recipe.number_of_steps == 1
      text += "Finally, the recipe has the following 1 step. #{recipe.steps[0]}. "
    elsif recipe.number_of_steps > 1
      text += "Finally, the recipe has the following #{recipe.number_of_steps} steps. "
      recipe.steps.each do |step|
        text += "#{step.sub(/\.*$/, "")} . "
      end
    end

    Response.new({
      text: text,
      shouldEndSession: true
    })
  end

  def bad_intent
    Response.new({
      text: "I don't understand the question and I won't respond to it.",
      shouldEndSession: true
    })
  end

end
