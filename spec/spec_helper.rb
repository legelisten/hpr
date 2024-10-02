require "rspec"
require "webmock/rspec"

require_relative "../lib/hpr"

def stub_hpr_request(number, fixture)
  number = 'empty' if number.empty?
  stub_request(:post, "https://register.helsedirektoratet.no/Hpr/Personnel").
       to_return(body: File.new("spec/fixtures/#{fixture}/#{number}.html"),
                 headers: {"Content-Type": "text/html"})
end
