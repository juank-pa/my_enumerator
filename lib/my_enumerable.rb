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

  alias map collect

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
end
