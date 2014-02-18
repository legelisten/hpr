require_relative "../spec_helper"

module Hpr
  describe "Dentist" do
    let(:number) { "3049523" }
    let(:period) { Date.new(1991, 7, 4)..Date.new(2041, 11, 5) }

    subject { Scraper.new(number) }

    before do
      stub_request(:get, "https://hpr.sak.no/Hpr/Hpr/Lookup?Number=#{number}").
        to_return(body: File.new("spec/fixtures/dentists/#{number}.html"))
    end

    it "scrapes the birth name" do
      expect(subject.name).to eq("ANNE GULBRANDSEN KHAZAIE")
    end

    it "scrapes the birth date" do
      expect(subject.birth_date).to eq(Date.new(1966, 11, 5))
    end

    it "scrapes the profession" do
      expect(subject.profession).to eq("Tannlege")
    end

    describe "approval" do
      it "scrapes the approval mechanism" do
        expect(subject.approval).to eq("Autorisasjon")
      end

      it "scrapes the approval period" do
        expect(subject.approval_period).to eq(period)
      end
    end

    describe "requisition law" do
      it "scrapes the requisition law procedure" do
        expect(subject.requisition_law).to eq("Full rekvisisjonsrett")
      end

      it "scrapes the requisition law period" do
        expect(subject.requisition_law_period).to eq(period)
      end
    end

    it "scrapes any specials" do
      expect(subject.specials).to be_empty
    end

    it "scrapes any additional expertise" do
      expertise = subject.additional_expertise
      expect(expertise).to have(1).item

      exp = expertise.first
      expect(exp.name).to eq("Godkjent implantatprotetisk behandler")
      expect(exp.period.first).to eq(Date.new(2011, 1, 5))
      expect(exp.period.last).to eq(Date.new(2041, 11, 5))
    end

    it "knows whether the internship has been approved" do
      expect(subject.approved_internship?).to be_false
    end
  end
end
