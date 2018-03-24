require_relative "../../spec_helper"

module Hpr
  describe "Chiropractor" do
    let(:number) { "6172733" }
    let(:fixture) { "chiropractors" }
    let(:html) { File.new("spec/fixtures/#{fixture}/#{number}.html") }

    let(:period) { Date.new(2014, 7, 2)..Date.new(2062, 3, 26) }

    subject { Scraper.new(number, html) }
    let(:chiropractor) { subject.chiropractor }

    it "scrapes the birth name" do
      expect(subject.name).to eq("BENEDICTE AAMBAKK")
    end

    it "scrapes the birth date" do
      expect(subject.birth_date).to eq(Date.new(1987, 03, 26))
    end

    it "scrapes the profession" do
      expect(subject.chiropractor?).to be_truthy
      expect(subject.physician?).to be_falsey
    end

    describe "approval" do
      it "scrapes the approval mechanism" do
        expect(chiropractor.approval).to eq("Autorisasjon")
      end

      it "scrapes the approval period" do
        expect(chiropractor.approval_period).to eq(period)
      end
    end

    it "scrapes any specials" do
      # As far as we know at the moment, no chiropractor specialities exist at all.
      expect(chiropractor.specials).to be_empty
    end

    it "scrapes any additional expertise" do
      expertise = chiropractor.additional_expertise
      expect(expertise.count).to equal(1)

      exp = expertise.first
      expect(exp.name).to eq("Sykemeldings- rekvisisjons- og henvisningsrett")
      expect(exp.period.first).to eq(Date.new(2014, 7, 2))
      expect(exp.period.last).to eq(Date.new(2062, 03, 26))
    end

    it "knows whether the internship has been approved" do
      expect(chiropractor.approved_internship?).to be_falsey
    end
  end
end
