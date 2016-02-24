class Request
  attr_reader :data, :type, :session, :intent, :ingredient_slot

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
    elsif @intent == "IngredientAmount"
      self.ingredient_amount
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

  def ingredient_amount
    query = @slots["Ingredient"]["value"]
    recipe = Recipe.first # this will change to look up the current user's active recipe
    ingredient_names = recipe["ingredients"].map { |i| i["name"] }
    response_text = ""

    ingredient_names.each do |ingredient|
      if query == ingredient || query.pluralize == ingredient || query.singularize == ingredient
        response_text += "You need #{recipe.format_ingredient(recipe.get_ingredient_hash(ingredient))}. "
      end
    end

    if response_text == ""
      list = "Here are the ingredients for #{recipe["name"]}. "
      recipe["ingredients"].each do |ingredient|
        list += recipe.format_ingredient(ingredient) + ", "
      end
      list += "."
      Response.new({
        text: "I couldn't find #{query} in this recipe. " + list,
        shouldEndSession: true
      })
    else
      Response.new({
        text: response_text,
        shouldEndSession: true
      })
    end
  end


end
