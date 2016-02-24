class Request

  def intitialize(info_hash)
    response = {
      "version": "0.1.1",
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": info_hash[:text]
        },
        "card": nil,
        "reprompt": nil,
        "shouldEndSession": info_hash[:shouldEndSession]
      },
      "sessionAttributes": info_hash[:sessionAttributes]
    }
    return response
  end

end
