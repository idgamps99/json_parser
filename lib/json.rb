require "strscan"

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
      tokens = tokenise(json)
      analyse_syntax(tokens)
    end

    def tokenise(json)
      json = StringScanner.new(json)
      tokens = []
      while !json.eos?
        if pattern = json.scan(/{/)
          tokens <<  token(LEFT_BRACE, pattern)
        elsif pattern = json.scan(/}/)
          tokens <<  token(RIGHT_BRACE, pattern)
        elsif pattern = json.scan(/'[a-zA-Z_', ]+'/) # any non numerical string including spaces and some punctuation
          tokens <<  token(STRING, pattern)
        elsif pattern = json.scan(/:/)
          tokens << token(COLON, pattern)
        elsif pattern = json.scan(/,/)
          tokens << token(COMMA, pattern)
        else
          json.pos += 1
        end
      end
      tokens
    end

    def token(type, pattern)
      { token_type: type, value: pattern }
    end

    def analyse_syntax(tokens)
      check_open_close_braces(tokens)
      tokens.pop
      tokens.shift

      hash = {}
      return hash if tokens.empty?
      previous = LEFT_BRACE

      tokens.each_with_index do |token, index|
        if valid_next_token?(token[:token_type], previous, tokens[index + 1])
          previous = token[:token_type]
          puts "FUCK YEAH #{token[:token_type]}"
        else
          puts token[:token_type]
        end
      end
    end

    def valid_next_token?(token_type, previous, follow)
      case previous
      when "LEFT_BRACE"
        token_type == STRING
      end
    end

    def check_open_close_braces(tokens)
      unless tokens[0][:token_type] == LEFT_BRACE
        error(expected: "{", unexpected: tokens[0][:value])
      end

      unless tokens[-1][:token_type] == RIGHT_BRACE
        error(expected: "}", unexpected: tokens[-1][:value])
      end
    end

    def error(expected: ____, unexpected: ____)
      raise ParseError, "unexpected token, expected '#{expected}', got '#{unexpected}'"
    end
  end
end
