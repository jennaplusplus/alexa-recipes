class Request
  attr_reader :data, :type, :session, :intent, :slots

  def initialize(params)
    @data = params
    @type = params["request"]["type"]
    @session = params["session"]
    if params["request"]["intent"]
      @intent = params["request"]["intent"]["name"]
      @slots = params["request"]["intent"]["slots"]
    end
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
      shouldEndSession: true,
      sessionAttributes: {"question": "list of ingredients"}
    })
  end

  # def launch
  #   Response.new({
  #     text: "Welcome to Recipes! Would you like a list of ingredients?",
  #     shouldEndSession: false,
  #     sessionAttributes: {"question": "list of ingredients"}
  #   })
  # end

  # methods = { "IngredientList" => :ingredient_list }
  # use send

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
    elsif @intent == "IngredientList"
      self.ingredient_list
    elsif @intent == "GetIngredient"
      self.get_ingredient
    elsif @intent == "GetCurrentStep"
      self.get_current_step
    elsif @intent == "GetNextStep"
      self.get_next_step
    elsif @intent == "ResetStep"
      self.reset_step
    elsif @intent == "GoToStep"
      self.go_to_step
    elsif @intent == "HowManySteps"
      self.how_many_steps
    elsif @intent == "GetPreviousStep"
      self.get_previous_step
    elsif @intent == "HowManyStepsLeft"
      self.how_many_steps_left
    elsif @intent == "GetRecipeName"
      self.get_recipe_name
    elsif @intent == "GoToRecipe"
      self.go_to_recipe
    elsif @intent == "RecipeList"
      self.recipe_list
    else
      self.no_intent
    end
  end

  def recipe_list
    recipes = Recipe.all
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
    recipe_name = @slots["Recipe"]["value"]
    recipe = Recipe.find_by(:name => /#{recipe_name}/i)
    if recipe
      Response.new({
        text: "I found your recipe for #{recipe["name"]}",
        shouldEndSession: true
      })
    end
  end

  def ingredient_list
    recipe = Recipe.first
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
    recipe = Recipe.first # this will change to look up the current user's active recipe

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
    recipe = Recipe.first
    steps = recipe.steps
    Response.new({
      text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"] - 1]}",
      shouldEndSession: true
    })
  end

  def get_next_step
    recipe = Recipe.first
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
    recipe = Recipe.first
    steps = recipe.steps
    recipe.reset_step
    Response.new({
      text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"] - 1]}",
      shouldEndSession: true
    })
  end

  def go_to_step
    query = @slots["Number"]["value"]
    recipe = Recipe.first
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
    recipe = Recipe.first
    Response.new({
      text: "This recipe has #{recipe.number_of_steps} steps.",
      shouldEndSession: true
    })
  end

  def get_previous_step
    recipe = Recipe.first
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
    recipe = Recipe.first
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
    recipe = Recipe.first
    Response.new({
      text: "This is your recipe for #{recipe["name"]}.",
      shouldEndSession: true
    })
  end

  def no_intent
    Response.new({
      text: "I don't understand the question and I won't respond to it.",
      shouldEndSession: true
    })
  end

end
