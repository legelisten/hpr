require_relative "../spec_helper"

module Hpr
  describe "Invalid identifier" do
    let(:number) { "3049647" }

    subject { Scraper.new(number) }

    before do
      stub_request(:get, "https://hpr.sak.no/Hpr/Hpr/Lookup?Number=#{number}").
        to_return(body: File.new("spec/fixtures/not_found/#{number}.html"))
    end

    it "raises an exception" do
      expect{ subject }.to raise_error(ArgumentError)
    end
  end
end
