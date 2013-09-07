# Call By Need

So yeah, uhm, you can read about what that means on [Wikipedia](http://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_need) (it's like an on-line encyclopedia type thing). Go and read it!

Now that you know what it is, let me disappoint you by narrowing the definition a little:

How does one do lazy evaluation in Ruby? By wrapping computations in lambdas and passing those around instead of their evaluated results. An instance of `CallByNeed::Context` is a somewhat usable container for lambdas. You're supposed to fill it with some names and computations that when evaluated yield the corresponding values for those names. That makes the evaluation of what's inside a `Context` lazy from the point of view of the part of the program that decided to pass around the ability to do certain things in the form of that `Context`.

The other ingredient is memoization. `Context` instances only ever evaluate names once (by calling the block assigned to that name), and reuse the result after.

If you use that more constrained definiton, the name makes a little more sense.

Let's see what using it looks like!

## Examples

### Simple memoization

```ruby
require 'call_by_need'

c = CallByNeed::Context.new do |c|
  c.declare(:b) { |x| x.a + 10 }
  c.declare(:a) { Time.now.utc }
end

Time.now.utc
# => 2013-09-07 14:48:50 UTC
sleep(5)
c.a
# => 2013-09-07 14:48:55 UTC
sleep(2)
c.b
# => 2013-09-07 14:49:05 UTC
c.a
# => 2013-09-07 14:48:55 UTC
```

### Merging of contexts

```ruby
require 'call_by_need'

c1 = CallByNeed::Context.new do |c|
  c.declare(:a, &:b) # b doesn't exist yet
  c.declare(:x) { |x| x.b + 'x' }
end

c1.a
# NoMethodError: undefined method `b'

c2 = CallByNeed::Context.new(c1) do |c|
  c.declare(:b) { 'b' }
end

c2.a
# => 'b'
c2.x
# => 'bx'
```

Every declaration yields the `Context` instance that it belongs to at the time of its evaluation into its block argument (named `x` in the example). That means you can combine multiple `Context` instances into one, and a `Context` field that was defined earlier is able to see anything that exists at the time of its evaluation.

### You can also give your contexts names

The next example shows some more elaborate potential usage context that involves slow things and fast things. It is also meant to demonstrate that using `call_by_name` doesn't harm readability in cases where memoization is not that essential. Just use it for everything! :D


```ruby
require 'call_by_need'
require 'benchmark'

class Genderizer
  def self.genders(name)
    [].tap do |_genders|
      _genders << :girl if girl?(name)
      _genders << :boy  if boy?(name)
    end
  end

  # slow method!
  def self.girl?(name)
    sleep(0.5)
    name =~ /^[amk]/
  end

  # another slow method!
  def self.boy?(name)
    sleep(0.5)
    name =~ /^[bk]/
  end
end

class People
  include CallByNeed

  def initialize(genderizer)
    declare(:kids) do
      [ 'alice', 'bob', 'marie', 'kim' ]
    end
    declare(:genders) do
      kids.inject({}) do |acc, name|
        acc.merge!(name => genderizer.genders(name))
      end
    end
    declare(:girls) do
      kids.select { |name| genders[name].include?(:girl) }
    end
    declare(:boys) do
      kids.select { |name| genders[name].include?(:boy) }
    end
    declare(:unknown) do
      boys & girls
    end
  end
end

people = People.new(Genderizer)
Benchmark.realtime { people.girls }
# => 4.005
people.evaluated?(:unknown)
# => false
Benchmark.realtime { people.unknown }
# => 0.00003
```

## Okay…?

So the whole thing is basically a generalized `||=`. But if you get used to passing around `Context` objects instead of lambdas or plain values, you get the laziness aspect on top of it.

The nice thing about it is that you can use it in an ad-hoc way to define anonymous memoizing contexts as a replacement for variables (add some non-determinism to your imperative code!), or as part of regular class definitions. And in both cases the syntax is pretty much the same.

But it doesn't do anything you couldn't do without it.
