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
    "HowManySteps"      => :how_many_steps,
    "GetPreviousStep"   => :get_previous_step,
    "HowManyStepsLeft"  => :how_many_steps_left,
    "GetRecipeName"     => :get_recipe_name,
    "GoToRecipe"        => :go_to_recipe,
    "RecipeList"        => :recipe_list
  }

  def intent
    if @intent == "AMAZON.YesIntent"
      if @session["attributes"]["question"] == "list of ingredients"
        self.ingredient_list
      end
    elsif @intent == "AMAZON.NoIntent"
      Response.new({
        text: "Ok.",
        shouldEndSession: true
      })
    elsif METHODS[@intent]
      if @intent != "GoToRecipe" && @intent != "RecipeList" && @user.active_recipe.nil?
        return Response.new({
          text: "Sorry, you don't have an open recipe.",
          shouldEndSession: true
        })
      else
        self.send(METHODS[@intent])
      end
    else
      self.bad_intent
    end
  end

  def recipe_list
    recipes = @user.recipes
    list = "Here are your available recipes. "
    recipes.each do |recipe|
      list += recipe["name"] + ", "
    end
    list += "."
    Response.new({
      text: list,
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
        text: "Sorry, you don't have any saved recipes.",
        shouldEndSession: true
      })
    end
    distances = recipes.get_pair_distances(target_recipe)
    ranked = distances.keys.sort_by { |key| distances[key] }.reverse!
    selection = ranked[0]
    if selection
      @user["active_recipe_id"] = selection.id
      @user.save
      return Response.new({
        text: "I found your recipe for #{selection["name"]}.",
        shouldEndSession: true
      })
    else
      Response.new({
        text: "Sorry, I couldn't access the recipe you asked for.",
        shouldEndSession: true
      })
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

  def go_to_step
    query = @slots["Number"]["value"]
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

  def bad_intent
    Response.new({
      text: "I don't understand the question and I won't respond to it.",
      shouldEndSession: true
    })
  end

end
