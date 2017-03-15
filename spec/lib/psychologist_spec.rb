require_relative "../spec_helper"

module Hpr
  describe "Psychologist" do
    let(:number) { "9108033" }
    let(:period) { Date.new(2004, 1, 9)..Date.new(2054, 9, 24) }

    subject { Scraper.new(number) }
    let(:psychologist) { subject.psychologist }

    before do
      stub_hpr_request(number, 'psychologists')
    end

    it "scrapes the birth name" do
      expect(subject.name).to eq("HEGE KRISTIN SÆTHERHAUG")
    end

    it "scrapes the birth date" do
      expect(subject.birth_date).to eq(Date.new(1974, 9, 24))
    end

    it "scrapes the profession" do
      expect(subject.psychologist?).to be_truthy
      expect(subject.physician?).to be_falsey
    end

    describe "approval" do
      it "scrapes the approval mechanism" do
        expect(psychologist.approval).to eq("Autorisasjon")
      end

      it "scrapes the approval period" do
        expect(psychologist.approval_period).to eq(period)
      end
    end

    it "scrapes any specials" do
      # As far as we know at the moment, no psychologist specialities exist at all.
      expect(psychologist.specials).to be_empty
    end

    it "knows whether the internship has been approved" do
      expect(psychologist.approved_internship?).to be_falsey
    end
  end
end
