# AddressTokens

Gem to find tokens on address strings. Can identify address, city and state name
and abbreviation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'address_tokens'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install address_tokens

## Usage

Always hated when you get some address like

```
88 Colin P Kelly Jr St San Francisco, CA 94107
```

and don't know where is the address, where is the state, where is the city name?

Ok, me too. So I made this class.

We need state and city data to find out what the tokens are. To load the date,
we'll need YAML files like [I have on this
repo](https://github.com/taq/brstatescities). They follow formats like these:

```
# states.yml:
---
CA: California

# cities.yml
CA:
- San Francisco
```

Finding by exact match is fast and piece of cake. The problem is where we have
some different ways to write or abbreviate the city names like we have here on
Brazil. For example, my city, São José do Rio Preto, can have some forms:

1. São José do Rio Preto
2. São José Rio Preto
3. S. J. do Rio Preto
4. S. J. R. Preto

And keep going. But I think I could find some ways to find that.

### Finding stuff

First, we create a Finder object:

```ruby
finder = AddressTokens::Finder.new('88 Colin P Kelly Jr St San Francisco, CA 94107')
```

Load the cities and states:

```ruby
finder.load(:states, '/tmp/states.yml')
finder.load(:cities, '/tmp/cities.yml')
finder.find
```

And ask to find:

```ruby
matches = finder.find
```

We'll get something like this:

```ruby
p matches
{
   :state_abbr     => "CA", 
   :state_name     => "California", 
   :state_start_at => 36,
   :city_name      => "San Francisco",
   :city_string    => "San Francisco",
   :city_start_at  => 23, 
   :address        => "88 Colin P Kelly Jr St"
}
```
The `start_at` values shows where the strings were found. The `city_string` is 
the way the city name was found.

### Custom options

As we saw, the default city and states separator on USA is a comma (','), but on
Brasil is a hyphen ('-'), so, **before asking to find the address**, we must
change it:

```ruby
finder.state_separator = '-'
```

Using a Brazilian address:

```ruby
finder = AddressTokens::Finder.new('Rua Tratado de Tordesihas, 88, Pq. Estoril,
S. J. do Rio Preto - SP')
finder.state_separator = '-'
finder.load(:states, '/tmp/states.yml')
finder.load(:cities, '/tmp/cities.yml')
finder.find
```

will return:

```ruby
{
   :state_abbr       => "SP", 
   :state_name       => "São Paulo", 
   :state_start_at   => 63, 
   :city_name        => "São José do Rio Preto", 
   :city_string      => "S. J. do Rio Preto", 
   :city_start_at    => 44, 
   :address          => "Rua Tratado de Tordesihas, 88, Pq. Estoril,"
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

Please run the tests using `rake test`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/taq/address_tokens.
