require_relative "../spec_helper"

module Hpr
  describe "Physician" do
    let(:number) { "2107538" }
    let(:period) { Date.new(1981, 2, 20)..Date.new(2027, 1, 16) }

    subject { Scraper.new(number) }
    let(:physician) { subject.physician }

    before do
      stub_request(:get, "https://hpr.sak.no/Hpr/Hpr/Lookup?Number=#{number}").
        to_return(body: File.new("spec/fixtures/physicians/#{number}.html"))
    end

    it "scrapes the birth name" do
      expect(subject.name).to eq("FINN JOHNSEN")
    end

    it "scrapes the birth date" do
      expect(subject.birth_date).to eq(Date.new(1952, 1, 16))
    end

    it "scrapes the profession" do
      expect(subject.physician?).to be_true
      expect(subject.dentist?).to be_false
    end

    describe "approval" do
      it "scrapes the approval mechanism" do
        expect(physician.approval).to eq("Autorisasjon")
      end

      it "scrapes the approval period" do
        expect(physician.approval_period).to eq(period)
      end
    end

    describe "requisition law" do
      it "scrapes the requisition law procedure" do
        expect(physician.requisition_law).to eq("Full rekvisisjonsrett")
      end

      it "scrapes the requisition law period" do
        expect(physician.requisition_law_period).to eq(period)
      end
    end

    it "scrapes any specials" do
      expect(physician.specials).to have(1).item
    end

    it "scrapes any additional expertise" do
      expect(physician.additional_expertise).to have(1).item
    end

    describe "approved internship" do
      it "knows whether the internship has been approved" do
        expect(physician.approved_internship?).to be_true
      end

      it "scrapes the approved internship date" do
        expect(physician.approved_internship_date).to eq(Date.new(1981, 2, 20))
      end
    end
  end
end
