When "I assign :ivar_name to :array" do |ivar, value|
  instance_variable_set(ivar, value)
end

When "I assign :ivar_name to :fixnum" do |ivar, value|
  instance_variable_set(ivar, value)
end

When "I assign :ivar_name to :float" do |ivar, value|
  instance_variable_set(ivar, value)
end

When "I assign :ivar_name to :hash" do |ivar, value|
  instance_variable_set(ivar, value)
end

Then ":ivar should be equal to :value" do |ivar, value|
  ivar.should == value
end

Then ":ivar should be a :class" do |ivar, klass|
  ivar.should be_kind_of(klass)
end

Pattern /a|an/
Pattern /is|are/

Pattern :array, /(\[.*\])/ do |array|
  eval(array)
end

Pattern :class, /([A-Z]\w*(?:::[A-Z]\w*)*)/ do |class_name|
  class_name.split(/::/).inject(Object) do |klass, subname|
    klass.const_get(subname)
  end
end

Pattern :fixnum, /(-?\d+)/ do |fixnum|
  fixnum.to_i
end

Pattern :float, /(-?\d+\.\d+)/ do |float|
  float.to_f
end

Pattern :hash, /(\{.*\})/ do |hash|
  eval(hash)
end

Pattern :ivar, /(@\w+)/ do |ivar_name|
  instance_variable_get(ivar_name)
end

Pattern :ivar_name, /(@\w+)/

Pattern :value, /(.*)/ do |expression|
  assert_pony!
  eval(expression)
end
