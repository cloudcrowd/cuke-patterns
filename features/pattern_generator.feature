Feature: Pattern Generator

Sometimes its nice to be able to have a catch-all like Ruby's method_missing
so we can do more dynamic things.  A PatternGenerator works like this, taking
a string of word characters representing a "word" or ":symbol" and then
returns a regexp and optional conversion proc.  If it returns neither, we
move on to the next defined Pattern Generator.

Scenario: singular/plural form agnosticizer
When I eat 1 apple
And I eat 2 apples
Then I should have eaten 3 apples

