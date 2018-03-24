require_relative "../../spec_helper"

module Hpr
  describe "Generic tests" do
    let(:number) { "6125735" } # Person without birth date specified
    let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }

    subject { Scraper.new(number, html) }

    context "with complete data returned from hpr" do
      let(:fixture) { "both" }

      it "returns nil when birthdate is n/a" do
        expect(subject.birth_date).to be_nil
      end
    end

    context "with corrupted data returned from hpr" do
      let(:fixture) { "corrupted_data" }

      it "raise exception" do
        expect{subject.birth_date}.to raise_error(Hpr::ScrapingError)
      end
    end
  end
end
