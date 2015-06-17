require_relative "../spec_helper"

module Hpr
  describe "Both" do
    let(:number) { "7122276" }

    subject { Scraper.new(number) }

    before do
      stub_hpr_request(number, 'both')
    end

    it "scrapes the birth name" do
      expect(subject.name).to eq("BJØRN KETIL BREVIK")
    end

    it "scrapes the birth date" do
      expect(subject.birth_date).to eq(Date.new(1961, 5, 1))
    end

    it "scrapes the profession" do
      expect(subject.physician?).to be_truthy
      expect(subject.dentist?).to be_truthy
    end

    describe "physician" do
      let(:physician) { subject.physician }
      let(:period) { Date.new(2001, 3, 22)..Date.new(2036, 5, 1) }

      describe "approval" do
        it "scrapes the approval mechanism" do
          expect(physician.approval).to eq("Autorisasjon")
        end

        it "scrapes the approval period" do
          expect(physician.approval_period).to eq(period)
        end
      end

      describe "requisition privilege" do
        it "scrapes the requisition privilege procedure" do
          expect(physician.requisition_privilege).to eq("Full rekvisisjonsrett")
        end

        it "scrapes the requisition privilege period" do
          expect(physician.requisition_privilege_period).to eq(period)
        end
      end

      it "scrapes any specials" do
        expect(physician.specials.count).to equal(1)
      end

      it "scrapes any additional expertise" do
        expect(physician.additional_expertise).to be_empty
      end

      describe "approved internship" do
        it "knows whether the internship has been approved" do
          expect(physician.approved_internship?).to be_truthy
        end

        it "scrapes the approved internship date" do
          expect(physician.approved_internship_date).to eq(Date.new(2001, 3, 22))
        end
      end
    end

    describe "dentist" do
      let(:dentist) { subject.dentist }
      let(:period) { Date.new(1987, 6, 16)..Date.new(2036, 5, 1) }

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
        expect(dentist.additional_expertise).to be_empty
      end

      it "knows whether the internship has been approved" do
        expect(dentist.approved_internship?).to be_falsey
      end
    end
  end
end
