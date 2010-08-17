Feature: PatternGenerator
  It would be useful to be able to hook the machinery that looks up
  defined patterns so that we can dynamically serve out a pattern
  regexp and proc when desired.  This would be similar to Ruby's
  Object#method_missing behavior.

Scenario: 3 PatternGenerators precedence example
  Given there is a PatternGenerator given "abc" returns nil
  And there is a PatternGenerator given "abc" returns /123/
  And there is a PatternGenerator given "abc" returns /456/
  When @x is the result of pattern lookup "abc"
  Then @x should be /123/
