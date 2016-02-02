require "rest_client"
require "nokogiri"

require "hpr/date_helper"
require "hpr/professional"

module Hpr
  class Scraper
    BASE_URL = "https://register.helsedirektoratet.no/Hpr/Hpr/Lookup".freeze
    PHYSICIAN = "Lege".freeze
    DENTIST = "Tannlege".freeze
    CHIROPRACTOR = "Kiropraktor".freeze
    NO_AUTHORIZATION = "Ingen autorisasjon".freeze

    include DateHelper

    attr_reader :hpr_number, :page

    def initialize(hpr_number)
      @hpr_number = hpr_number
      @page = Nokogiri::HTML(RestClient.post(BASE_URL, {"Number" => hpr_number}))

      if hpr_number_not_found?
        raise Hpr::InvalidHprNumberError, "HPR number: #{hpr_number}"
      elsif person_has_lost_authorization?
        raise Hpr::MissingMedicalAuthorizationError, "HPR number: #{hpr_number}"
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

    def person_has_lost_authorization?
      approval_boxes.length == 1 && approval_boxes[0].at_css("h3").text.strip == NO_AUTHORIZATION
    end
  end
end
