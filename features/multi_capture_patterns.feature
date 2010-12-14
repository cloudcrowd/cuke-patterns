Feature: Multi-capture Patterns
Here are some examples of patterns that yield more than one
capture from the Regexp into the transform closure.

Scenario: :quoted
When I assign @x to "hello"
Then @x should be equal to 'hello'
And @x should be a String

Scenario: multiple transform patterns
When I assign @x to a set of 3 "things"
Then @x should be equal to ['things','things','things']
And @x should be an Array

Scenario: multiple multi-capture transform patterns
When I assign @x to "word1" + "word2"
Then @x should be equal to 'word1word2'
And @x should be a String

