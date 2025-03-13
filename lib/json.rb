# 1 : validate a simple JSON object "{}"
# 2 : validate an object with a string key and string value
# 3 : validate an object with string, numeric, boolean and null values
# 4 : validate an object with object and array values
module JSON
  LEFT_BRACE    = "LEFT_BRACE"
  RIGHT_BRACE   = "RIGHT_BRACE"
  # LEFT_BRACKET  = "LEFT_BRACKET"
  # RIGHT_BRACKET = "RIGHT_BRACKET"
  # COLON         = "COLON"
  # COMMA         = "COMMA"
  # STRING        = "STRING"
  # NUMBER        = "NUMBER"
  # TRUE          = "TRUE"
  # FALSE         = "FALSE"
  ParseError = Class.new(StandardError)

  class << self
    def parse(json)
      tokens = tokenise(json)
      unless verify_braces(tokens)
        raise ParseError, "Invalid object, expecting {} - received _____"
      end
      analyse_syntax(tokens, {}, 0)
    end

    def tokenise(json)
      json.each_char.map do |char|
        case char
        when "{" then { token_type: LEFT_BRACE, value: char }
        when "}" then { token_type: RIGHT_BRACE, value: char }
        end
      end
    end

    def verify_braces(tokens)
      tokens[0][:token_type] == LEFT_BRACE && tokens[-1][:token_type] == RIGHT_BRACE
    end

    def analyse_syntax(tokens, hash, position)
      return hash if tokens.length == position
      position += 1
      analyse_syntax(tokens, hash, position)
    end
  end
end
