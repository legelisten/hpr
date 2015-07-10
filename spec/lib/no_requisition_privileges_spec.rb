require_relative "../spec_helper"

module Hpr
  context 'Missing requisition privileges' do
    let(:scraper) { Scraper.new(number) }

    context 'requisition privileges' do
      let(:number) { "9364684" }
      let(:professional) { Professional.new(scraper.physician_approval_box) }

      before do
        stub_hpr_request(number, 'no_requisition_rights')
      end

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
