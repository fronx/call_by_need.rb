require 'bundler/setup'
require 'call_by_need'

class CallByNeedTest
  include CallByNeed
  attr_reader :a
  def initialize(a)
    @a = a
  end
end

describe CallByNeed do
  let(:object) do
    CallByNeedTest.new(123)
  end

  it "executes in the calling scope" do
    @a = nil
    object.a.should == 123
    object.declare(:foo) { @a = 3 * 9 }
    object.foo.should == 27
    @a.should == 27
  end
end

describe CallByNeed::Context do
  def something
    @x ||= "something"
  end

  let(:context) do
    CallByNeed::Context.new do |c|
      c.declare(:a) { something }
      c.declare(:b) { something + something }
    end
  end

  it "disallows overwriting values" do
    lambda do
      context.declare(:a) { "boo" }
    end.should raise_error(CallByNeed::DuplicateVarError)
  end

  it "throws an error when reading nonexisting values" do
    lambda do
      context.get(:x)
    end.should raise_error(CallByNeed::VarMissingError)
  end

  it "can read values repeatedly" do
    context.a.should == 'something'
    context.a.should == 'something'
  end

  it "executes the block for a name once" do
    context.a.should == 'something' # cached hereafter
    @x = 'else'
    context.a.should == 'something' # memoized
    context.b.should == 'elseelse'  # evaluated later --> different value
  end

  it "allows self-references" do
    context = CallByNeed::Context.new do |c|
      c.declare(:x) { 2 * c.y }
      c.declare(:z) { 3 * c.x }
      c.declare(:y) { 4 }
    end
    context.z.should == 24
  end

  it "can be merged" do
    c1 = CallByNeed::Context.new { |c| c.declare(:a) { 1 } }
    c2 = CallByNeed::Context.new { |c| c.declare(:b) { 2 } }
    c3 = c1.merge(c2)
    c3.a.should == 1
    c3.b.should == 2
  end

  it "can inherit" do
    c1 = CallByNeed::Context.new { |c| c.declare(:a) { 2 } }
    c2 = CallByNeed::Context.new(c1) { |c| c.declare(:b) { c.a * 4 } }
    c2.a.should == 2
    c2.b.should == 8
  end

  it "doesn't care what the order of dependent declarations is" do
    CallByNeed::Context.new do |c|
      c.declare(:a, &:b)
      c.declare(:b) { 'b' }
    end.a.should == 'b'
    c1 = CallByNeed::Context.new do |c|
      c.declare(:a, &:b)
      c.declare(:x) { |x| x.b + 'x' }
    end
    c2 = CallByNeed::Context.new do |c|
      c.declare(:b) { 'b' }
    end
    c2.merge(c1).a.should == 'b'
    c2.merge(c1).x.should == 'bx'
  end
end
