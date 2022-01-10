require_relative "../../spec_helper"

module Hpr
  describe "Generic tests" do
    subject { Scraper.new(number, html) }

    context "with complete data returned from hpr" do
      let(:number) { "6125735" } # Person without birth date specified
      let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }
      let(:fixture) { "both" }

      it "returns nil when birthdate is n/a" do
        expect(subject.birth_date).to be_nil
      end

      it "returns nil when deceased date is n/a" do
        expect(subject.deceased_date).to be_nil
      end
    end

    context "with corrupted data returned from hpr" do
      let(:number) { "6125735" } # Person without birth date specified
      let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }
      let(:fixture) { "corrupted_data" }

      it "raise exception" do
        expect{subject.birth_date}.to raise_error(Hpr::ScrapingError)
      end
    end

    context "with extra html elements returned in approval info" do
      let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }
      let(:fixture) { :approval_badge }
      let(:number) { '2107538' }

      it 'strips off the extra html' do
        expect(subject.physician.approval).to eq 'Begrenset autorisasjon med vilkår'
      end
    end
  end
end
