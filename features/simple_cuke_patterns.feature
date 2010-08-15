Feature: Simple Cuke Patterns

Scenario: Transform string of digits into Fixnum
  When @x is 1234
  Then @x should be a Fixnum
  And @x should evaluate to 1234

Scenario: Transform digits with negative sign into Fixnum
  When @x is -1234
  Then @x should be a Fixnum
  And @x should evaluate to -1234

Scenario: Transform a list to an array of Fixnums
  When @x contains 1, 2, 3 and 4
  Then @x should be an Array
  And @x should evaluate to [1, 2, 3, 4]
