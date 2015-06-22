require_relative "../spec_helper"

module Hpr
  describe "Person has HPR entry, but no authorization" do

    let(:scraper) { Scraper.new(number) }

    context "person used to be authorized in single category" do
      let(:number) { "6133290" }

      before do
        stub_hpr_request(number, 'lost_authorization')
      end

      it "raises an exception" do
        expect{ scraper }.to raise_error(Scraper::MissingMedicalAuthorizationError)
      end
    end

    context 'person used to be authorized in multiple categories' do
      let(:number) { "6128459" }
      let(:professional) { Professional.new(scraper.dentist_approval_box) }

      before do
        stub_hpr_request(number, 'lost_authorization')
      end

      describe 'approved?' do
        it 'returns false' do
          expect(professional.approved?).to eq false
        end
      end
    end
  end
end
