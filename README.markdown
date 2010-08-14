Welcome to the 'cuke-patterns' gem

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
