When ":ivar_name contains :list" do |ivar, array|
  instance_variable_set(ivar, array)
end

Pattern :list, /(.+(?:,| and ).+)/ do |list|
  assert_pony!
  list.split(/ *(?:,|and) */).map do |item|
    Pattern :value, item
  end
end
