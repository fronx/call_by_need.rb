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

c.a
# => 2013-09-07 14:48:55 UTC
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

## Okay…

It's basically just a generalized `||=`. So maybe the name is a little misleading.
