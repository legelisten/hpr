require 'mechanize'

module Hpr
  class Fetcher
    BASE_URL = "https://register.helsedirektoratet.no/Hpr".freeze
    FORM_ACTION = "/Hpr/Personnel".freeze
    AGENT_ALIASES = ["Linux Firefox",
                     "Mac Firefox",
                     "Mac Safari",
                     "Windows Edge",
                     "Windows Firefox",
                     "Windows IE 11",
                     "iPhone",
                     "iPad",
                     "Android"]

    def initialize(hpr_number)
      @hpr_number = hpr_number
    end

    def fetch
      mechanize.get(BASE_URL) do |page|
        @page = page.form_with(action: FORM_ACTION) do |f|
          f.Number = hpr_number
        end.submit

        if hpr_number_not_found?
          raise Hpr::InvalidHprNumberError, "HPR number: #{hpr_number}"
        end
      end

      @page.body
    end

  private

    attr_reader :page, :hpr_number

    def hpr_number_not_found?
      !page.search("//text()[contains(.,'HPR-nummer ikke funnet') or contains(.,'Vennligst oppgi HPR/ID-nummer')]").empty?
    end

    def mechanize
      ::Mechanize.new do |agent|
        agent.user_agent_alias = AGENT_ALIASES.sample
      end
    end
  end
end
