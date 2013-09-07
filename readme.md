# Call By Need

So yeah, uhm, you can read about what that means on [Wikipedia](http://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_need). It's like an on-line encyclopedia type thing.

## Example

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

## Okay…

So it's basically just a generalized `||=`.
