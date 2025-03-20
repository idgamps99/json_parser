require_relative "../lib/json"

RSpec.describe "JSON.parse" do
  include JSON
  let(:json) { "{ 'key': 'value' }" }

  context "parses" do
    it "a simple JSON object {}" do
      expect(JSON.parse("{}")).to eq({})
    end

    it "a string key-value pair" do
      expect(JSON.parse(json)).to eq({ 'key' => 'value' })
    end

    it "multiple string key-value pairs" do
      multiple_pairs = "{
          'key': 'value',
          'another_key': 'another_value',
          'final key': 'final value'
        }"
      expected = {
        'key' => 'value',
        'another_key' => 'another_value',
        'final key' => 'final value'
      }
      expect(JSON.parse(multiple_pairs)).to eq(expected)
    end
  end

  context "rejects" do
    it "object not opened with curley brace" do
      expect{ JSON.parse("}") }.to raise_error(JSON::ParseError)
    end

    it "object not closed with curley brace" do
      expect{ JSON.parse("{") }.to raise_error(JSON::ParseError)
    end

    it "object with key-value pairs not closed with }" do
      multiple_pairs = "{
          'key': 'value',
          'another_key': 'another_value',
          'final key': 'final value'"
        expect{ JSON.parse(multiple_pairs) }.to raise_error(JSON::ParseError, "unexpected token, expected '}', got 'final value'")
    end

    it "object with a dangling comma" do
      multiple_pairs = "{
          'key': 'value',
          'another_key': 'another_value',
          'final key': 'final value',"
        expect{ JSON.parse(multiple_pairs) }.to raise_error(JSON::ParseError)
    end
  end
end
