class Request
  attr_reader :data, :type, :session, :intent, :ingredient_slot

  def initialize(params)
    @data = params
    @type = params["request"]["type"]
    @session = params["session"]
    @intent = params["request"]["intent"]["name"]
    @ingredient_slot = params["request"]["intent"]["slots"]["Ingredient"]["value"]
  end

  def route
    if @type == "LaunchRequest"
      launch
    elsif @type == "IntentRequest"
      intent
    end
  end

  def launch
    Response.new({
      text: "Welcome to Recipes! Would you like a list of ingredients?",
      shouldEndSession: false,
      sessionAttributes: {"question": "list of ingredients"}
    })
  end

end
