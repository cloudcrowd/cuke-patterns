Pattern :quoted, /"([^"]*)"|'([^']*)'/ do |double, single|
  double.to_s + single.to_s
end

When "I assign :ivar_name to :quoted" do |ivar, quoted|
  instance_variable_set(ivar, quoted)
end

When "I assign :ivar_name to :quoted + :quoted" do |ivar, q1, q2|
  instance_variable_set(ivar, q1+q2)
end

When "I assign :ivar_name to a set of :fixnum :quoted" do |ivar, count, quoted|
  set = []
  1.upto(count) { set.push(quoted) }
  instance_variable_set(ivar, set)
end
