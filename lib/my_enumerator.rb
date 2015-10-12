require 'fiber'
require 'my_enumerable'

class MyEnumerator
  include MyEnumerable

  attr_reader :size

  def initialize(*args, &block)
    case args.size
    when (0..1)
      @size = args.first
      @object = Generator.new(block)
      @method = :each
    else
      @object = args.first
      @method = args.size > 1 ? args[1] : :each
      @args = args[2..-1]
    end
    @args ||= []
    rewind
  end

  def size
    case @size
    when Proc
      @size.call
    when nil
      @object.size if @object.respond_to?(:size)
    else
      @size
    end
  end

  def peek_values
    peek_using(:next_values)
  end

  def peek
    peek_using(:next)
  end

  def next_values
    @value = yielder.transfer(@feed) if yielder.alive?
    raise ::MyStopIteration.new(@value) unless yielder.alive?

    @at_start = false unless @peek
    @peek = false unless @peeklock
    @feed = nil
    @value
  end

  def next
    next_values
    @value = !@value.nil? && @value.size <= 1 ? @value[0] : @value
  end

  def feed(value)
    @feed = value; nil
  end

  def rewind
    return self if @at_start
    @at_start = true
    @yielder = Yielder.new do |y|
      @object.send(@method, *@args) do |*args|
        val = y.yield(args)
        redo if @peek
        val
      end
    end
    self
  end

  def each(*appending_args, &block)
    rewind

    enum = appending_args.empty? ?
      self : MyEnumerator.new(@object, @method, *(@args + appending_args))
    value = nil

    if enum.equal?(self)
      loop { feed(block.call(self.next)) } if block
    else
      value = enum.each(&block) if block
    end

    return enum unless block
    rewind
    value || @value
  end

  def inspect
    args = @args.size == 0? '' : "(#{@args.map(&:inspect).join(', ')})"
    "#<#{self.class}: #{@object.inspect}#{@method.inspect}#{args}>"
  end

  def each_with_index(&block)
    with_index(&block)
  end

  def with_index(offset = 0)
    return my_enum_for(__method__) unless block_given?
    index = offset - 1
    each { |*elem| yield(*elem, index += 1) }
  end

  alias with_object each_with_object

  private

  attr_reader :yielder

  def peek_using(method)
    @peeklock = true
    self.send(method)
    @peek = true
    @peeklock = false
    @value
  end
end

class MyEnumerator
  class Generator
    include MyEnumerable

    def initialize(block)
      @block = block
    end

    def rewind
      @yielder = Yielder.new do |y|
          @block.call(y)
      end
    end

    def each
      rewind
      yield(*@yielder.transfer) while @yielder.alive?
    end

    alias inspect to_s
  end

  class Yielder
    @@stack = []

    def self.pop
      @@stack.pop
    end

    def self.push(yielder)
      @@stack << yielder if yielder != @@stack.last
    end

    def self.top
      @@stack.last
    end

    def self.empty?
      @@stack.empty?
    end

    def self.finish_all
      @@stack.each(&:finish)
      @@stack = []
    end

    def initialize(&block)
      @alive = true
      @fiber = Fiber.new do
        value = block.call(self)
        Yielder.finish_all
        value
      end
    end

    def yield(*args)
      Yielder.pop
      unless Yielder.empty?
        Yielder.top.transfer(*args)
      else
        Fiber.yield(*args)
      end
    end

    alias << yield

    def alive?
      @alive && @fiber.alive?
    end

    def finish
      @alive = false
    end

    def transfer(*args)
      Yielder.push self
      @fiber.transfer(*args) if alive?
    end

    alias inspect to_s
  end
end

class MyStopIteration < StandardError
  attr_reader :result

  def initialize(result = nil)
    super("iteration reached an end")
    @result = result
  end
end

class Object
  def to_my_enum(method = :each, *args)
    MyEnumerator.new(self, method, *args)
  end

  alias my_enum_for to_my_enum
  alias my_enumerator_old_loop loop

  def loop(&block)
    my_enumerator_old_loop(&block)
  rescue MyStopIteration
  end
end
