module JSON
  # 1 : validate a simple JSON object "{}"
  # 2 : validate an object with a string key and string value
  # 3 : validate an object with string, numeric, boolean and null values
  # 4 : validate an object with object and array values

  LEFT_BRACE    = "LEFT_BRACE"
  RIGHT_BRACE   = "RIGHT_BRACE"
  # LEFT_BRACKET  = "LEFT_BRACKET"
  # RIGHT_BRACKET = "RIGHT_BRACKET"
  COLON         = "COLON"
  COMMA         = "COMMA"
  STRING        = "STRING"
  # NUMBER        = "NUMBER"
  # TRUE          = "TRUE"
  # FALSE         = "FALSE"
  ParseError = Class.new(StandardError)

  class << self
    def parse(json)
      tokens = tokenise(json).compact
      tokens.each { |token| p token }
      verify_braces(tokens)
      analyse_syntax(tokens, {}, 1)
    end

    def tokenise(json)
      json.split(/[\s']/).map do |char|
        case char
        when " " then next
        when "{" then { token_type: LEFT_BRACE, value: char }
        when "}" then { token_type: RIGHT_BRACE, value: char }
        when /[a-zA-Z]/ then{ token_type: STRING, value: char }
        when ":" then { token_type: COLON, value: char }
        when "," then { token_type: COMMA, value: char }
        end
      end
    end

    def verify_braces(tokens)
      unless tokens[0][:token_type] == LEFT_BRACE
        error(expected: "{", unexpected: tokens[0][:value])
      end

      unless tokens[-1][:token_type] == RIGHT_BRACE
        error(expected: "}", unexpected: tokens[-1][:value])
      end
    end

    def analyse_syntax(tokens, hash, position)
      return hash if tokens.length - 1 == position
      position += 1
      analyse_syntax(tokens, hash, position)
    end

    def error(expected: ____, unexpected: ____)
      raise ParseError, "unexpected token, expected '#{expected}', got '#{unexpected}'"
    end
  end
end

test = "{ 'key': 'value', 'another_key': 'another_value' }"

JSON.parse(test)
