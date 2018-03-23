require_relative "../../spec_helper"

module Hpr
  describe "Person has HPR entry, but no authorization" do
    let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }

    let(:scraper) { Scraper.new(number, html) }

    context "person used to be authorized in single category" do
      let(:number) { "6133290" }
      let(:fixture) { "lost_authorization" }

      it "raises an exception" do
        expect{ scraper }.to raise_error(MissingMedicalAuthorizationError)
      end
    end

    context 'person used to be authorized in multiple categories' do
      let(:number) { "6128459" }
      let(:fixture) { "lost_authorization" }
      let(:professional) { Professional.new(scraper.dentist_approval_box) }

      describe '#approved?' do
        it 'returns false' do
          expect(professional.approved?).to eq false
        end
      end

      describe '#approval_period' do
        # When person has lost authorization, they can have an authorization
        # line with the text "Ingen gjeldende autorisasjon." and an empty
        # approval period.
        it 'returns nil' do
          expect(professional.approval_period).to eq nil
        end
      end
    end
  end
end
