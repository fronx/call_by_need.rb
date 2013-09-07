# Call By Need

So yeah, uhm, you can read about what that means on [Wikipedia](http://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_need). It's like an on-line encyclopedia type thing.

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

### You can also give your contexts names

This example is ultimately pointless, but it shows some more elaborate potential usage context that involves slow things and fast things.

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

  def self.girl?(name)
    sleep(0.5)
    name =~ /^[amk]/
  end

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

## Okay…

It's basically just a generalized `||=`. So maybe the name is a little misleading.
