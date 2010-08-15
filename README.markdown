# cuke-patterns

Makes cucumber step definitions more focused, understandable, searchable and awesomeable.

 * Author: Brendan Baldwin <brendan@usergenic.com>
 * Github: http://github.com/brendan/cuke-patterns

## What does it do?

(This gem is only relevant if you're using cucumber already.)

Change your step definition files from this:

    When /^(\w+) withdraws \$(\d+\(?:\.\d+)?)$/ do |name, amount|
      customer = Bank::Customer.find_by_name(name)
      amount = BigDecimal.new(amount)
      Bank::Teller.withdraw_for(customer, amount)
    end

Into this:

    When ":customer withdraws :dollar_amount" do |customer, amount|
      Bank::Teller.withdraw_for(customer, amount)
    end

    Pattern :customer, /(\w+)/ do |name|
      Bank::Customer.find_by_name(name)
    end

    Pattern :dollar_amount, /\$(\d+\(?:.\d+)?)/ do |amount|
      BigDecimal.new(amount)
    end

Patterns are kind of like Transforms in cucumber, except Patterns are designed to be
referenced in Step definitions by name as opposed to recognized by form automatically.

To use it, just pop this in your app's support/env.rb which gets loaded by cucumber:

    require 'rubygems'
    require 'cuke-patterns'

## Notes on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Brendan Baldwin. See LICENSE for details.
