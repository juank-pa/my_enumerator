require 'my_enumerable'

class LinkedList
  include MyEnumerable

  attr_accessor :value
  attr_reader :tail

  def initialize(value, list = nil)
    @value = value
    @tail = list
  end

  def each
    if block_given?
      list = self
      while list
        yield list.value
        list = list.tail
      end
    else
      nil
    end
  end
end

class EnumerableClass
  include Enumerable
  def each
    yield 1
    yield 2
    yield 'hola'
    8
  end
end

class MyEnumerableClass < EnumerableClass
  include MyEnumerable
end

