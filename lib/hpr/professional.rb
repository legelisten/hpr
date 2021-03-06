require "nokogiri"

require "hpr/date_helper"
require "hpr/additional_expertise"
require "hpr/specials"

module Hpr
  class Professional
    APPROVAL = "Godkjenning".freeze
    REQUISITION_PRIVILEGE = "Rekvisisjonsrett".freeze
    ADDITIONAL_EXPERTISE = "Tilleggskompetanse".freeze
    APPROVED_INTERSHIP = "Godkjent turnus".freeze
    YES = "Ja".freeze
    SPECIALS = "Spesialitet".freeze
    NO_AUTHORIZATION = "Ingen gjeldende autorisasjon".freeze

    include DateHelper

    # approval_box - as returned from Hpr::Scraper
    def initialize(approval_box)
      @approval_box = approval_box
    end

    def approved?
      approval_row && !approval.include?(NO_AUTHORIZATION)
    end

    def approval
      @approval ||= begin
        approval_contents = approval_row.at_css(".cell2")

        # Remove badges and any other HTML included
        extra_html = approval_contents.at_css('*')
        extra_html.remove if extra_html

        approval_contents.text.strip
      end
    end

    def approval_period
      unless instance_variable_defined?(:@approval_period)
        @approval_period = period(approval_row)
      end
      @approval_period
    end

    def requisition_privilege
      if requisition_privilege_row
        @requisition_privilege ||= requisition_privilege_row.at_css(".cell2").text.strip
      end
    end

    def requisition_privilege_period
      if requisition_privilege_row
        @requisition_privilege_period ||= period(requisition_privilege_row)
      end
    end

    def additional_expertise
      @additional_expertise ||= additional_expertise_rows.to_a.map do |row|
        name = row.at_css(".cell2").text.strip
        AdditionalExpertise.new(name, period(row))
      end
    end

    def approved_internship?
      unless instance_variable_defined?(:@approved_internship)
        @approved_internship = begin
          approved_internship_row ? approved_internship_row.at_css(".cell2").text == YES : false
        end
      end
      @approved_internship
    end

    def approved_internship_date
      str_to_date(approved_internship_row.at_css(".cell3").text) if approved_internship?
    end

    def specials
      @specials ||= specials_rows.to_a.map do |row|
        name = row.at_css(".cell2").text.strip
        Specials.new(name, period(row))
      end
    end

  private

    def specials_rows
      @specials_rows = entries.select { |entry| entry.at_css(".cell1").text.strip == SPECIALS }
    end

    def approved_internship_row
      unless instance_variable_defined?(:@approved_internship_row)
        @approved_internship_row = entries.find { |entry| entry.at_css(".cell1").text.strip == APPROVED_INTERSHIP }
      end
      @approved_internship_row
    end

    def additional_expertise_rows
      @additional_expertise_rows = entries.select { |entry| entry.at_css(".cell1").text.strip == ADDITIONAL_EXPERTISE }
    end

    def requisition_privilege_row
      unless instance_variable_defined?(:@requisition_privilege_row)
        @requisition_privilege_row = entries.find { |entry| entry.at_css(".cell1").text.strip == REQUISITION_PRIVILEGE }
      end
      @requisition_privilege_row
    end

    def period(row)
      date_from = date_from(row)
      if date_from
        to = row.at_css(".cell6").text.lstrip!
        date_to = str_to_date(to)
        (date_from..date_to) if date_to
      end
    end

    def date_from(row)
      if row.at_css(".cell4")
        from = row.at_css(".cell4").text.lstrip!
        str_to_date(from)
      end
    end

    def approval_row
      unless instance_variable_defined?(:@approval_row)
        @approval_row = entries.find { |entry| entry.at_css(".cell1").text.strip == APPROVAL }
      end
      @approval_row
    end

    def entries
      @entries ||= @approval_box.css(".data-entry")
    end
  end
end
