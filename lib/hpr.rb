# encoding: utf-8

require "hpr/version"
require "hpr/scraper"

module Hpr
  class MissingMedicalAuthorizationError < ArgumentError; end
  class InvalidHprNumberError < MissingMedicalAuthorizationError; end
  class ScrapingError < ArgumentError; end 
end
