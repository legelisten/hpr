require_relative "../../spec_helper"

module Hpr
  describe "Person has HPR entry, is dead" do
    let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }
    let(:scraper) { Scraper.new(number, html) }

    let(:number) { "2125809" }
    let(:fixture) { "deceased" }

    it "returns true" do
      expect(scraper.person_is_deceased?).to eq true
    end
  end
end
