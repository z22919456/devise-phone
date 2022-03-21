# Devise::Phone

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/devise/phone`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'devise-phone'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install devise-phone

## Getting Started

After you installed Devise Phone you need to run the generator.

```ruby
rails generate devise_phone:install
rails generate devise_phone MODEL
```

The generator adds optional configurations to config/initializers/devise_phone.rb. Devise Phone provide 2 models, you cans add to your Devise models:

```ruby
devise :phone_confirmable, :otp_verify
```

TODO: 還沒翻譯完，也還沒寫完


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/devise-phone.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
