module MyEnumerable
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
end
