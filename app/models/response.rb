class Response

  def initialize(info_hash)
    @version = "0.1.1"
    @response = {
      "outputSpeech" => {
        "type" => "PlainText",
        "text" => info_hash[:text]
      },
      "card" => nil,
      "reprompt" => nil,
      "shouldEndSession" => info_hash[:shouldEndSession]
    }
    @sessionAttributes = info_hash[:sessionAttributes]
  end

  def with_ssml(text)
    @response["outputSpeech"]["type"] = "SSML"
    @reponse["outputSpeech"]["text"] = text
  end

end
