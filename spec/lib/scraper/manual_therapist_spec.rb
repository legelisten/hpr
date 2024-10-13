# frozen_string_literal: true

require_relative '../../spec_helper'

module Hpr
  describe 'Manual therapist' do
    let(:number) { '6028721' }
    let(:fixture) { 'manual_therapists' }
    let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }

    let(:period) { Date.new(2023, 3, 1)..Date.new(2033, 5, 14) }

    subject { Scraper.new(number, html) }
    let(:manual_therapist) { subject.manual_therapist }

    it 'scrapes the birth name' do
      expect(subject.name).to eq('PETER CHRISTIAN LEHNE')
    end

    it 'scrapes the birth date' do
      expect(subject.birth_date).to eq(Date.new(1953, 5, 14))
    end

    it 'scrapes the profession' do
      expect(subject.manual_therapist?).to be_truthy
      expect(subject.physician?).to be_falsey
    end

    describe 'approval' do
      it 'scrapes the approval mechanism' do
        expect(manual_therapist.approval).to eq('Autorisasjon')
      end

      it 'scrapes the approval period' do
        expect(manual_therapist.approval_period).to eq(period)
      end
    end

    it 'scrapes any specials' do
      expect(manual_therapist.specials).to be_empty
    end
  end
end
