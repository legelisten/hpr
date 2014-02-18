# Hpr

Ruby wrapper for Helsepersonellregisteret (HPR).

## Installation

Add this line to your application's Gemfile:

    gem 'hpr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hpr

## Usage

```ruby
require "hpr"

scraper = Hpr::Scraper.new(3049523)
scraper.birth_date # => #<Date: 1966-11-05 ((2439435j,0s,0n),+0s,2299161j)>
scraper.dentist? # => true
dentist = scraper.dentist
dentist.approval # => "Autorisasjon"
dentist.approval_period # => #<Date: 1991-07-04 ((2448442j,0s,0n),+0s,2299161j)>..#<Date: 2041-11-05 ((2466829j,0s,0n),+0s,2299161j)>
dentist.additional_expertise # => [#<struct Hpr::AdditionalExpertise name="Godkjent implantatprotetisk behandler", period=#<Date: 2011-01-05 ((2455567j,0s,0n),+0s,2299161j)>..#<Date: 2041-11-05 ((2466829j,0s,0n),+0s,2299161j)>>]
# ..
```

## Contributing

1. Fork it ( http://github.com/legelisten/hpr-cristian/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
>>>>>>> First commit
