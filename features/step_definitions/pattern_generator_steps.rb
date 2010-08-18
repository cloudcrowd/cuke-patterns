When "I eat :value apples" do |count|
  @apples_consumed ||= 0
  @apples_consumed += count
end

Then "I should have eaten :value apples" do |count|
  @apples_consumed.should == count
end

# This pattern generator doesn't do *real* pluralize/singularize;
# it's just a demonstration of the concept.  Here I strip and append
# an 's' onto the word passed in and construct a regexp that looks
# for all forms rather naively.
PatternGenerator do |word|
  base_plural_singular = [word, word+'s', word.sub(/s$/,'')].uniq
  base_plural_singular.map! {|w| Regexp.escape(w)}
  Regexp.new(base_plural_singular.join('|'))
end
