require_relative "../spec_helper"

module Hpr
  describe "Person has HPR entry, but no authorization" do

    subject { Scraper.new(number) }

    context "non-existing hpr number" do
      let(:number) { "6133290" }

      before do
        stub_hpr_request(number, 'lost_authorization')
      end

      it "raises an exception" do
        expect{ subject }.to raise_error(Scraper::MissingMedicalAuthorizationError)
      end
    end
  end
end
