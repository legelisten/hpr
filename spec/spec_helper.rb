require "rspec"
require "webmock/rspec"

require_relative "../lib/hpr"

def stub_hpr_request(number, fixture)
  if number.empty?
    number = 'empty'
    return stub_request(:post, "https://register.helsedirektoratet.no/Hpr/Hpr/Lookup").
        with(:body => {"Number"=>""},
             :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', \
             'Content-Length'=>'7', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
        to_return(body: File.new("spec/fixtures/#{fixture}/#{number}.html"))
  end
  stub_request(:post, "https://register.helsedirektoratet.no/Hpr/Hpr/Lookup").
        with(
        headers: {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'14', \
        'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
        to_return(body: File.new("spec/fixtures/#{fixture}/#{number}.html"))
end
