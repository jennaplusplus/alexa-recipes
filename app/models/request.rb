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
      text: "Welcome to Recipes! Would you like a list of ingredients?",
      shouldEndSession: false,
      sessionAttributes: {"question": "list of ingredients"}
    })
  end

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

    query_set = Set.new
    query.split.each do |word|
      query_set.add(word)
      query_set.add(word.singularize)
      query_set.add(word.pluralize)
    end

    matches = recipe["ingredients"].select do |ingredient|
      query_set.any? { |word| ingredient["name"].include?(word)}
    end

    if matches.length == 0
      response = "I couldn't find that in this recipe. "
      response += "Here are the ingredients for #{recipe["name"]}. "
      recipe["ingredients"].each do |ingredient|
        response += recipe.format_ingredient(ingredient) + ", "
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
      text: "Step #{recipe["current_step"]} of #{recipe.number_of_steps}: #{steps[recipe["current_step"].to_i - 1]}",
      shouldEndSession: true
    })
  end


end
