Feature: Simple Patterns
These are some examples of very simple but useful patterns.

Scenario: :fixnum
When I assign @x to 1
Then @x should be equal to 1
And @x should be a Fixnum

Scenario: :fixnum (negative)
When I assign @x to -1
Then @x should be equal to -1
And @x should be a Fixnum

Scenario: :float
When I assign @x to 2.0
Then @x should be equal to 2.0
And @x should be a Float

Scenario: :float (negative)
When I assign @x to -2.0
Then @x should be equal to -2.0
And @x should be a Float

Scenario: :hash
When I assign @x to {'a'=>'b','c'=>'d'}
Then @x should be equal to {'a'=>'b','c'=>'d'}
And @x should be a Hash

Scenario: :array
When I assign @x to [1,2,3]
Then @x should be equal to [1,2,3]
And @x should be an Array

Scenario: :string
When I assign @x to "aww yeah"
Then @x should be equal to "aww yeah"
And @x should be a String



