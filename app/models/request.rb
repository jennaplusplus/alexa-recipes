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
    elsif @intent == "IngredientAmount" || @intent == "IngredientNeeded"
      self.ingredient_amount
    end
  end

  def ingredient_list
    recipe = Recipe.first
    list = "Here are the ingredients for #{recipe["name"]}. "
    recipe["ingredients"].each do |ingredient|
      if ingredient["unit"].nil?
        list += "#{ingredient["measurement"]} #{ingredient["name"]}, "
      else
        list += "#{ingredient["measurement"]} #{ingredient["unit"]} of #{ingredient["name"]}, "
      end
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
        response_text += "You need #{ingredient}. "
      end
    end

    if response_text == ""
      Response.new({
        text: "I couldn't find #{query} in this recipe.",
        shouldEndSession: true
      })
    else
      Response.new({
        text: response_text,
        shouldEndSession: true
      })
    end



    # if ingredient_names.include?(query)
    #   ing = recipe["ingredients"].detect { |ingredient| ingredient["name"] == query }
    #   if ing["unit"].nil?
    #     Response.new({
    #       text: "You need #{ing["measurement"]} #{ing["name"]}. ",
    #       shouldEndSession: true
    #     })
    #   else
    #     Response.new({
    #       text: "You need #{ing["measurement"]} #{ing["unit"]} of #{ing["name"]}. ",
    #       shouldEndSession: true
    #     })
    #   end
    # else
    #   Response.new({
    #     text: "I couldn't find #{query} in this recipe.",
    #     shouldEndSession: true
    #   })
    # end
  end


end
