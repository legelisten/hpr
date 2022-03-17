# encoding: utf-8

require 'bundler/setup'
require "hpr/version"
require "hpr/scraper"
require "hpr/fetcher"

module Hpr
  class MissingMedicalAuthorizationError < ArgumentError; end
  class InvalidHprNumberError < MissingMedicalAuthorizationError; end
  class ScrapingError < ArgumentError; end

  def self.scraper(hpr_number:)
    html = Fetcher.new(hpr_number).fetch
    Scraper.new(hpr_number, html)
  end
end
