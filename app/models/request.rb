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
      Recipe.ingredient_list
    elsif @intent == "IngredientAmount" || @intent == "IngredientNeeded"
      Recipe.ingredient_amount(params)
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


end
