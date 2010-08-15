When "@x is :integer" do |integer|
  @x = integer
end

When "@x contains :list_of_integers" do |list|
  @x = list
end

Then "@x should be a :class" do |klass|
  @x.class.should == klass
end

Then /^@x should evaluate to (.*)$/ do |expression|
  @x.should == eval(expression)
end

Pattern 'a',  /a|an/
Pattern 'an', /a|an/

Pattern :class, /([A-Z][a-z]+)/ do |class_name|
  Object.const_get(class_name)
end

Pattern :integer, /(-?\d+)/ do |number|
  number.to_i
end

Pattern :list_of_integers, /(-?\d+(?: *(?:,|and) *-?\d+)*)/ do |list|
  list.split(/ *(?:,|and) */).map{|number| number.to_i}
end
