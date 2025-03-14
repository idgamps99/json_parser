require_relative "../lib/json"

RSpec.describe "JSON.parse" do
  include JSON
  let(:json) { "{ 'key': 'value' }" }

  context "parses" do
    it "a simple JSON object {}" do
      expect(JSON.parse("{}")).to eq({})
    end

    it "a string key-value pair" do
      expect(JSON.parse(json)).to eq(false) 
    end
  end

  context "rejects" do
    it "object not opened with curley brace" do
      expect{ JSON.parse("}") }.to raise_error(JSON::ParseError)
    end

    it "object not closed with curley brace" do
      expect{ JSON.parse("{") }.to raise_error(JSON::ParseError)
    end
  end
end
