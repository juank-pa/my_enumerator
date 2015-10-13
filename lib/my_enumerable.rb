module MyEnumerable
  def all?
    if block_given?
      each { |elem| return false unless yield(elem) }
      true
    else
      all? { |elem| elem }
    end
  end

  def any?
    if block_given?
      each { |elem| return true if yield(elem) }
      false
    else
      any? { |elem| elem }
    end
  end

  def collect
    return my_enum_for(__method__) unless block_given?
    [].tap { |arr| each { |*args| arr << yield(*args) } }
  end

  def collect_concat
    return my_enum_for(__method__) unless block_given?
    [].tap { |arr| each { |*args| arr << yield(*args) } }.flatten(1)
  end

  def count(item = nil)
    if block_given?
      inject(0) { |elem, sum| sum + (yield(elem) ? 1 : 0) }
    elsif item.nil?
      count { true }
    else
      count { |elem| elem == item }
    end
  end

  def cycle(n = nil)
    return my_enum_for(__method__) unless block_given?
    if n.nil?
      loop { each { |elem| yield(elem) } }
    elsif n > 0
      n.times { each { |elem| yield(elem) }  }; nil
    end
  end

  def detect(ifnone = nil)
    return my_enum_for(__method__) unless block_given?
    each { |elem| return elem if yield(elem) }
    ifnone.call if ifnone
  end

  def drop(n)
    drop_while { (n -= 1) >= 0 }
  end

  def drop_while
    return my_enum_for(__method__) unless block_given?
    to_a.tap do |arr|
      each_with_index { |elem, index| return arr[index..-1] unless yield(elem) }
    end
  end

  alias find detect

  def inject(*args, &block)
    acc, sym, collection = inject_params(*args)
    if sym
      collection.inject(acc) { |elem, acc| elem.send(sym, acc) }
    else
      collection.each { |elem| acc = yield(elem, acc)}
      acc
    end
  end

  alias map collect

  alias reduce inject

  def each_with_index(*args)
    return my_enum_for(__method__, *args) unless block_given?
    index = -1
    each(*args) { |elem| yield(elem, index += 1) }
  end

  def each_with_object(obj)
    return my_enum_for(__method__, obj) unless block_given?
    each { |elem| yield(elem, obj) }
    obj
  end

  def to_a
    map { |elem| elem }
  end

  private

  def inject_params(first_arg = nil, second_arg = nil)
    case first_arg
    when nil
      [first, nil, drop(1)]
    when Symbol
      [first, first_arg, drop(1)]
    else
      [first_arg, second_arg, self]
    end
  end
end
