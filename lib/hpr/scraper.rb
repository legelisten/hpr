# frozen_string_literal: true

require 'nokogiri'

require 'hpr/date_helper'
require 'hpr/professional'

module Hpr
  class Scraper
    PHYSICIAN = 'Lege'
    DENTIST = 'Tannlege'
    CHIROPRACTOR = 'Kiropraktor'
    PSYCHOLOGIST = 'Psykolog'
    MANUAL_THERAPIST = 'Manuellterapeut'
    NO_AUTHORIZATION = 'Ingen autorisasjon'

    include DateHelper

    attr_reader :hpr_number, :page

    def initialize(hpr_number, html)
      @hpr_number = hpr_number
      @page = Nokogiri::HTML(html)
    end

    def name
      @name ||= person_header.at_css('h2').text.gsub(/\s{2,}/, ' ')
    end

    def birth_date
      @birth_date ||= begin
        birth_date_para = person_header.at_css('p').text
        birth_date_str = birth_date_para[/Fødselsdato: (\d{2}[.]\d{2}[.]\d{4})/, 1]
        birth_date_str ? str_to_date(birth_date_str) : nil
      end
    end

    def deceased_date
      @deceased_date ||= begin
        birth_date_para = person_header.at_css('p').text
        birth_date_str = birth_date_para[/Død: (\d{2}[.]\d{2}[.]\d{4})/, 1]
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
      !!physician
    end

    def dentist
      unless instance_variable_defined?(:@dentist)
        @dentist = dentist_approval_box ? Professional.new(dentist_approval_box) : nil
      end
      @dentist
    end

    def dentist?
      !!dentist
    end

    def chiropractor
      unless instance_variable_defined?(:@chiropractor)
        @chiropractor = chiropractor_approval_box ? Professional.new(chiropractor_approval_box) : nil
      end
      @chiropractor
    end

    def chiropractor?
      !!chiropractor
    end

    def psychologist
      unless instance_variable_defined?(:@psychologist)
        @psychologist = psychologist_approval_box ? Professional.new(psychologist_approval_box) : nil
      end
      @psychologist
    end

    def psychologist?
      !!psychologist
    end

    def manual_therapist
      unless instance_variable_defined?(:@manual_therapist)
        @manual_therapist = manual_therapist_approval_box ? Professional.new(manual_therapist_approval_box) : nil
      end
      @manual_therapist
    end

    def manual_therapist?
      !!manual_therapist
    end

    def physiotherapist
      unless instance_variable_defined?(:@physiotherapist)
        @physiotherapist = physiotherapist_approval_box ? Professional.new(physiotherapist_approval_box) : nil
      end
      @physiotherapist
    end

    def physiotherapist?
      !!physiotherapist
    end

    def osteopath
      unless instance_variable_defined?(:@osteopath)
        @osteopath = osteopath_approval_box ? Professional.new(osteopath_approval_box) : nil
      end
      @osteopath
    end

    def osteopath?
      !!osteopath
    end

    def naprapath
      unless instance_variable_defined?(:@naprapath)
        @naprapath = naprapath_approval_box ? Professional.new(naprapath_approval_box) : nil
      end
      @naprapath
    end

    def naprapath?
      !!naprapath
    end

    def dental_hygienist
      unless instance_variable_defined?(:@dental_hygienist)
        @dental_hygienist = dental_hygienist_approval_box ? Professional.new(dental_hygienist_approval_box) : nil
      end
      @dental_hygienist
    end

    def dental_hygienist?
      !!dental_hygienist
    end

    def dentist_approval_box
      unless instance_variable_defined?(:@dentist_approval_box)
        @dentist_approval_box = approval_boxes.find { |box| box.at_css('h3').text.strip == DENTIST }
      end
      @dentist_approval_box
    end

    def physician_approval_box
      unless instance_variable_defined?(:@physician_approval_box)
        @physician_approval_box = approval_boxes.find { |box| box.at_css('h3').text.strip == PHYSICIAN }
      end
      @physician_approval_box
    end

    def psychologist_approval_box
      unless instance_variable_defined?(:@psychologist_approval_box)
        @psychologist_approval_box = approval_boxes.find { |box| box.at_css('h3').text.strip == PSYCHOLOGIST }
      end
      @psychologist_approval_box
    end

    def chiropractor_approval_box
      unless instance_variable_defined?(:@chiropractor_approval_box)
        @chiropractor_approval_box = approval_boxes.find { |box| box.at_css('h3').text.strip == CHIROPRACTOR }
      end
      @chiropractor_approval_box
    end

    def manual_therapist_approval_box
      unless instance_variable_defined?(:@manual_therapist_approval_box)
        @manual_therapist_approval_box = approval_boxes.find { |box| box.at_css('h3').text.strip == MANUAL_THERAPIST }
      end
      @manual_therapist_approval_box
    end

    def physiotherapist_approval_box
      unless instance_variable_defined?(:@physiotherapist_approval_box)
        @physiotherapist_approval = approval_boxes.find { |box| box.at_css('h3').text.strip == 'Fysioterapeut' }
      end
      @physiotherapist_approval
    end

    def osteopath_approval_box
      unless instance_variable_defined?(:@osteopath_approval_box)
        @osteopath_approval_box = approval_boxes.find { |box| box.at_css('h3').text.strip == 'Osteopat' }
      end
      @osteopath_approval_box
    end

    def naprapath_approval_box
      unless instance_variable_defined?(:@naprapath_approval_box)
        @naprapath_approval_box = approval_boxes.find { |box| box.at_css('h3').text.strip == 'Naprapat' }
      end
      @naprapath_approval_box
    end

    def dental_hygienist_approval_box
      unless instance_variable_defined?(:@dental_hygienist_approval_box)
        @dental_hygienist_approval_box = approval_boxes.find { |box| box.at_css('h3').text.strip == 'Tannpleier' }
      end
      @dental_hygienist_approval_box
    end

    def approval_boxes
      @approval_boxes ||= page.css('.approval-box')
    end

    def person_header
      @person_header ||= page.at_css('.person-header')
      raise Hpr::ScrapingError, "Hpr number: #{hpr_number}" unless @person_header

      @person_header
    end

    def person_has_lost_authorization?
      approval_boxes.length == 1 && approval_boxes[0].at_css('h3').text.strip == NO_AUTHORIZATION
    end

    def person_is_deceased?
      deceased_date != nil
    end
  end
end
