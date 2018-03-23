require_relative "../spec_helper"

describe Hpr do

  context 'scraper' do
    let(:number) { '3049523' }
    before do
      stub_request(:get, "https://register.helsedirektoratet.no/Hpr").
      to_return(body: File.new("spec/fixtures/index.html"),
      headers: {"Content-Type": "text/html"})

      stub_hpr_request(number, 'dentists')
    end

    it 'returns a Scraper object' do
      expect(Hpr.scraper(hpr_number: number).class).to eq Hpr::Scraper
    end
  end
end
