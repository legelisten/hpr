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
        page.body = html_bugfix(page.body) # This can hopefully be removed in the future
        @page = submit_search_form(page)
        @page.body = html_bugfix(@page.body)

        if hpr_number_not_found?
          raise Hpr::InvalidHprNumberError, "HPR number: #{hpr_number}"
        end
      end

      html_bugfix(@page.body)
    end

  private

    attr_reader :page, :hpr_number

    def hpr_number_not_found?
      # All permutations of "not found" we've encountered. Some of these
      # may be outdated. The latest found is added last.
      !page.search("//text()[contains(.,'HPR-nummer ikke funnet') \
        or contains(.,'Vennligst oppgi HPR/ID-nummer') \
        or contains(.,'Fant ingen personer')]").empty?
    end

    def mechanize
      ::Mechanize.new do |agent|
        agent.user_agent_alias = AGENT_ALIASES.sample
      end
    end

    def submit_search_form(page)
      form = page.forms_with(action: FORM_ACTION)[0]
      form['hprNumber'] = hpr_number
      form['handler'] = 'HprNumberSubmit'
      form.submit
    end

    ##
    # Fixes a self closing opening <html> tag that Mechanize can't handle
    #
    # The current version of the HPR website has a self closing <html> tag
    # that Mechanize can't handle. This method fixes that by removing the
    # self closing slash and parsing the HTML using Nokogiri, which is better
    # at handling broken HTML. This correctly adds the closing </html> tag.
    #
    # Hopefully this can be removed by the time you read this.
    #
    def html_bugfix(html)
      html.gsub!('<html lang="en" />', '<html lang="en">')
      Nokogiri::HTML(html).to_html
    end
  end
end
