Feature: Apply Pattern

Patterns can be called from within other Patterns.

Scenario: A list pattern
When @x contains 1, "potato", 2.0 and "potato"
Then @x should be equal to [1, "potato", 2.0, "potato"]
And @x should be an Array
