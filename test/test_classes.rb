require 'my_enumerable'

class LinkedList
  include MyEnumerable

  attr_accessor :value
  attr_reader :tail

  def initialize(value, list = nil)
    @value = value
    @tail = list
  end

  def insert(value)
    LinkedList.new(value, self)
  end

  def size
    return 1 if tail.nil?
    1 + tail.size
  end

  def each
    list = self
    while list
      yield list.value
      list = list.tail
    end
    self
  end

  def inspect
    "#{@value.inspect} -> #{@tail.inspect}"
  end

  alias to_s inspect
end
