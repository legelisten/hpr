require_relative "../spec_helper"

module Hpr
  describe "Generic tests" do
    let(:number) { "6125735" } # Person without birth date specified

    subject { Scraper.new(number) }

    context "with complete data returned from hpr" do
      before do
        stub_hpr_request(number, 'both')
      end

      it "returns nil when birthdate is n/a" do
        expect(subject.birth_date).to be_nil
      end
    end

    context "with corrupted data returned from hpr" do
      before do
        stub_hpr_request(number, 'corrupted_data')
      end

      it "raise exception" do
        expect{subject.birth_date}.to raise_error(Hpr::ScrapingError)
      end
    end
  end
end
