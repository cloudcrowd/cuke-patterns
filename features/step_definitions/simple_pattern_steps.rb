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

Pattern :class, /([A-Z][a-z]+)/ do |class_name|
  Object.const_get(class_name)
end

Pattern :integer, /(-?\d+)/ do |number|
  number.to_i
end

Pattern :list_of_integers, /(-?\d+(?: *(?:,|and) *-?\d+)*)/ do |list|
  list.split(/ *(?:,|and) */).map{|number| number.to_i}
end

PatternGenerator do |key|
  %w[a an].include?(key) and /a|an/
end

## This PatternGenerator would enable automatic singularize/pluralize of ALL words
## so you don't have to resort to regexp construction for steps just do deal with
## pluralization related nonsense.
#
# PatternGenerator do |key|
#   Regexp.new([Regexp.escape(key.singularize), Regexp.escape(key.pluralize)].join('|'))
# end
