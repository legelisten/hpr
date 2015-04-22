# encoding: utf-8

require "nokogiri"
require "rest_client"

require_relative "hpr/version"

module Hpr
  module DateHelper
    DATE_FORMAT = "%d.%m.%Y".freeze

    def str_to_date(str)
      begin
        Date.strptime(str, DATE_FORMAT)
      rescue ArgumentError; end
    end
  end

  class AdditionalExpertise < Struct.new(:name, :period); end
  class Specials < AdditionalExpertise; end

  class Professional
    APPROVAL = "Godkjenning".freeze
    REQUISITION_LAW = "Rekvisisjonsrett".freeze
    ADDITIONAL_EXPERTISE = "Tilleggskompetanse".freeze
    APPROVED_INTERSHIP = "Godkjent turnus".freeze
    YES = "Ja".freeze
    SPECIALS = "Spesialitet".freeze

    include DateHelper

    def initialize(approval_box)
      @approval_box = approval_box
    end

    def approval
      @approval ||= approval_row.at_css(".cell2").text.strip
    end

    def approval_period
      unless instance_variable_defined?(:@approval_period)
        @approval_period = period(approval_row)
      end
      @approval_period
    end

    def requisition_law
      @requisition_law ||= requisition_law_row.at_css(".cell2").text.strip
    end

    def requisition_law_period
      unless instance_variable_defined?(:@requisition_law_period)
        @requisition_law_period = period(requisition_law_row)
      end
      @requisition_law_period
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

    def requisition_law_row
      unless instance_variable_defined?(:@requisition_law_row)
        @requisition_law_row = entries.find { |entry| entry.at_css(".cell1").text.strip == REQUISITION_LAW }
      end
      @requisition_law_row
    end

    def period(row)
      from = row.at_css(".cell4").text.lstrip!
      date_from = str_to_date(from)
      if date_from
        to = row.at_css(".cell6").text.lstrip!
        date_to = str_to_date(to)
        (date_from..date_to) if date_to
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

  class Scraper
    class InvalidHprNumberError < ArgumentError; end

    BASE_URL = "https://hpr.sak.no/Hpr/Hpr/Lookup".freeze
    PHYSICIAN = "Lege".freeze
    DENTIST = "Tannlege".freeze
    CHIROPRACTOR = "Kiropraktor".freeze

    include DateHelper

    attr_reader :page

    def initialize(number)
      @page = Nokogiri::HTML(RestClient.post(BASE_URL, {"Number" => number}))

      if hpr_number_not_found?
        raise InvalidHprNumberError, "HPR number: #{number}"
      end
    end

    def name
      @name ||= person_header.at_css("h2").text.gsub(/\s{2,}/, " ")
    end

    def birth_date
      @birth_date ||= begin
        birth_date_para = person_header.at_css("p").text
        birth_date_str = birth_date_para[/Fødselsdato: (\d{2}[.]\d{2}[.]\d{4})/, 1]
        birth_date_str ? str_to_date(birth_date_str) : nil
      end
    end

    def physician
      unless instance_variable_defined?(:@physician)
        @physician = physician_approval_box ? Professional.new(physician_approval_box) : nil
      end
      @physician
    end

    def physician?
      !! physician
    end

    def dentist
      unless instance_variable_defined?(:@dentist)
        @dentist = dentist_approval_box ? Professional.new(dentist_approval_box) : nil
      end
      @dentist
    end

    def dentist?
      !! dentist
    end

    def chiropractor
      unless instance_variable_defined?(:@chiropractor)
        @chiropractor = chiropractor_approval_box ? Professional.new(chiropractor_approval_box) : nil
      end
      @chiropractor
    end

    def chiropractor?
      !! chiropractor
    end

    def dentist_approval_box
      unless instance_variable_defined?(:@dentist_approval_box)
        @dentist_approval_box = approval_boxes.find { |box| box.at_css("h3").text.strip == DENTIST }
      end
      @dentist_approval_box
    end

    def physician_approval_box
      unless instance_variable_defined?(:@physician_approval_box)
        @physician_approval_box = approval_boxes.find { |box| box.at_css("h3").text.strip == PHYSICIAN }
      end
      @physician_approval_box
    end

    def chiropractor_approval_box
      unless instance_variable_defined?(:@chiropractor_approval_box)
        @chiropractor_approval_box = approval_boxes.find { |box| box.at_css("h3").text.strip == CHIROPRACTOR }
      end
      @chiropractor_approval_box
    end

    def approval_boxes
      @approval_boxes ||= page.css(".approval-box")
    end

    def person_header
      @person_header ||= page.at_css(".person-header")
    end

  private

    def hpr_number_not_found?
      !!@page.at_xpath("//text()[contains(.,'HPR-nummer ikke funnet') or contains(.,'Vennligst oppgi HPR/ID-nummer')]")
    end
  end
end
