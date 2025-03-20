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

  class TreeNode
    attr_reader :key, :value

    def initialize(key: nil, value: none)
      @key = key
      @value = value
    end

    def self.root(root)
      @@root = root
    end
  end

  class << self
    def parse(json)
      unless json.is_a?(String)
        if json.respond_to?(:to_s)
          json.to_s
        else
          error(expected: "JSON string", unexpected: json.class)
        end
      end
      @nodes = []
      @tokens = create_tokens(json)
      analyse_syntax
      build_json
    end

    def create_tokens(json)
      json = StringScanner.new(json)
      tokens = []
      until json.eos?
        if pattern = json.scan(/{/)
          tokens << token(LEFT_BRACE, pattern)
        elsif pattern = json.scan(/}/)
          tokens << token(RIGHT_BRACE, pattern)
        elsif pattern = json.scan(/'[a-zA-Z_', ]+'/) # any non numerical string including spaces and some punctuation
          tokens << token(STRING, pattern.gsub(/'/, ""))
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

    def analyse_syntax
      index = 0
      if @tokens[0][:token_type] != LEFT_BRACE
        error(expected: "{", unexpected: @tokens[0][:value])
      elsif @tokens[-1][:token_type] != RIGHT_BRACE
        error(expected: "}", unexpected: @tokens[-1][:value])
      end

      while index < @tokens.length
        @current = @tokens[index]
        @previous = @tokens[index - 1] unless @current[:token_type] == LEFT_BRACE
        @next = @tokens[index + 1]


        case @current[:token_type]
        when LEFT_BRACE
          unless @next[:token_type] == STRING || @next[:token_type] == RIGHT_BRACE
            error(expected: STRING, unexpected: @next[:value])
          end
          index += 1
        when STRING
          unless @next[:token_type] == COLON || @next[:token_type] == COMMA || @next[:token_type] == RIGHT_BRACE
            error(expected: ": or , or }", unexpected: @next[:token_type])
          end
          index += 1
        when COLON
          @nodes << TreeNode.new(key: @previous[:value], value: @next[:value]) if check_adjacent?
          index += 1
        when COMMA
          check_adjacent?
          index += 1
        when RIGHT_BRACE
          index += 1
        else
          error(expected: "unknown", unexpected: @current[:value])
        end
      end
    end

    def build_json
      json = {}
      @nodes.each do |node|
        json[node.key] = node.value
      end
      json
    end

    def check_adjacent?
      if @previous[:token_type] != STRING
        error(expected: STRING, unexpected: @previous[:value])
      elsif @next[:token_type] != STRING
        error(expected: STRING, unexpected: @next[:value])
      end
      true
    end

    def error(expected: nil, unexpected: nil)
      raise ParseError, "unexpected token, expected '#{expected}', got '#{unexpected}'"
    end
  end
end
