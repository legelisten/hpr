require_relative "../spec_helper"

module Hpr
  describe "Invalid identifier" do

    subject { Scraper.new(number) }

    context "non-existing hpr number" do
      let(:number) { "3049647" }

      before do
        stub_hpr_request(number, 'not_found')
      end

      it "raises an exception" do
        expect{ subject }.to raise_error(InvalidHprNumberError)
      end
    end

    context "empty hpr number" do
      let(:number) { '' }

      before do
        stub_hpr_request(number, 'not_found')
      end

      it "raises an exception" do
        expect{ subject }.to raise_error(InvalidHprNumberError)
      end
    end
  end
end
