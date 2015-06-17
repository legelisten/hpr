require_relative "../spec_helper"

module Hpr
  describe "Dentist" do
    let(:number) { "3049523" }
    let(:period) { Date.new(1991, 7, 4)..Date.new(2041, 11, 5) }

    subject { Scraper.new(number) }
    let(:dentist) { subject.dentist }

    before do
      stub_hpr_request(number, 'dentists')
    end

    it "scrapes the birth name" do
      expect(subject.name).to eq("ANNE GULBRANDSEN KHAZAIE")
    end

    it "scrapes the birth date" do
      expect(subject.birth_date).to eq(Date.new(1966, 11, 5))
    end

    it "scrapes the profession" do
      expect(subject.dentist?).to be_truthy
      expect(subject.physician?).to be_falsey
    end

    describe "approval" do
      it "scrapes the approval mechanism" do
        expect(dentist.approval).to eq("Autorisasjon")
      end

      it "scrapes the approval period" do
        expect(dentist.approval_period).to eq(period)
      end
    end

    describe "requisition privilege" do
      it "scrapes the requisition privilege procedure" do
        expect(dentist.requisition_privilege).to eq("Full rekvisisjonsrett")
      end

      it "scrapes the requisition privilege period" do
        expect(dentist.requisition_privilege_period).to eq(period)
      end
    end

    it "scrapes any specials" do
      expect(dentist.specials).to be_empty
    end

    it "scrapes any additional expertise" do
      expertise = dentist.additional_expertise
      expect(expertise.count).to equal(1)

      exp = expertise.first
      expect(exp.name).to eq("Godkjent implantatprotetisk behandler")
      expect(exp.period.first).to eq(Date.new(2011, 1, 5))
      expect(exp.period.last).to eq(Date.new(2041, 11, 5))
    end

    it "knows whether the internship has been approved" do
      expect(dentist.approved_internship?).to be_falsey
    end
  end
end
