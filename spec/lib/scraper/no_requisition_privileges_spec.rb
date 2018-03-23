require_relative "../../spec_helper"

module Hpr
  context 'Missing requisition privileges' do
    let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }
    let(:scraper) { Scraper.new(number, html) }

    context 'requisition privileges' do
      let(:number) { "9364684" }
      let(:fixture) { "no_requisition_rights" }
      let(:professional) { Professional.new(scraper.physician_approval_box) }

      context 'privilege name' do
        it 'returns nil' do
          expect(professional.requisition_privilege).to eq nil
        end
      end

      context 'privilege period' do
        it 'returns nil' do
          expect(professional.requisition_privilege_period).to eq nil
        end
      end
    end
  end
end
