class Response

  def initialize(info_hash)
    @version = "0.1.1"
    @response = {
      "outputSpeech" => {
        "type" => "PlainText",
        "text" => HTMLEntities.new.encode(info_hash[:text])
      },
      "card" => nil,
      "reprompt" => nil,
      "shouldEndSession" => info_hash[:shouldEndSession]
    }
    @sessionAttributes = info_hash[:sessionAttributes]
  end

end
