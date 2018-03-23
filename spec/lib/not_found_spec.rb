require_relative "../spec_helper"

module Hpr
  describe "Invalid identifier" do
    subject { Fetcher.new(hpr_number: number) }

    before do
      stub_request(:get, "https://register.helsedirektoratet.no/Hpr").
             to_return(body: File.new("spec/fixtures/index.html"),
                       headers: {"Content-Type": "text/html"})
    end

    context "non-existing hpr number" do
      let(:number) { "3049647" }
      let(:fixture) { "not_found" }

      before do
        stub_hpr_request(number, 'not_found')
      end

      it "raises an exception" do
        expect{ subject.fetch }.to raise_error(InvalidHprNumberError)
      end
    end

    context "empty hpr number" do
      let(:number) { '' }

      before do
        stub_hpr_request(number, 'not_found')
      end

      it "raises an exception" do
        expect{ subject.fetch }.to raise_error(InvalidHprNumberError)
      end
    end
  end
end
