require 'my_enumerator'
require 'test_classes'
require 'minitest/autorun'

class TestEnumerable < Minitest::Test
  def setup
    values = [2, 5, 87, 100, 32, 45, 10, 7, 41]
    @list = values.reduce(nil) { |head, elem| LinkedList.new(elem, head) }
    @values = values.reverse
    @nil_list = values.reduce(nil) { |head, elem| LinkedList.new((elem if elem < 62), head) }
  end

  def test_all?
    exec_asserts(false, :all?) { |elem| elem.even? }
    exec_asserts(true, :all?) { |elem| elem < 150 }
    assert_predicate @list, :all?
    refute_predicate @nil_list, :all?
  end

  def test_any?
    exec_asserts(true, :any?) { |elem| elem.even? }
    exec_asserts(false, :any?) { |elem| elem > 150 }
    assert_predicate @list, :any?
    assert_predicate @nil_list, :any?
  end

  def test_collect_or_map
    block = -> elem { elem * 5 }
    exp = @values.map(&block)
    exec_asserts(exp, :map, &block)
    exec_asserts(exp, :collect, &block)
    assert_kind_of MyEnumerator, @list.collect
  end

  def test_collect_concat
    block = -> elem { [elem * 5, [elem]] }
    exp = @values.collect_concat(&block)
    exec_asserts(exp, :collect_concat, &block)
    assert_kind_of MyEnumerator, @list.collect_concat
  end

  def test_count
    exec_asserts(5, :count) { |elem| elem.odd? }
    assert_equal 1, @list.count(5)
    assert_equal @list.size, @list.count
  end

  def test_cycle
    exec_asserts(nil, :cycle, 2) {}
    val = [].tap { |arr| @list.cycle(2){ |elem| arr << elem } }
    assert_equal (@values * 2), val
    assert_kind_of MyEnumerator, @list.cycle
  end

  def test_detect_find
    exec_asserts(45, :detect) { |elem| elem >= 42 }
    exec_asserts(nil, :find) { |elem| elem >= 1000 }
    exec_asserts('none', :detect, -> {'none'}) { |elem| elem >= 1000 }
    assert_kind_of MyEnumerator, @list.find
  end

  def test_drop
    assert_equal @values[3..-1], @list.drop(3)
  end

  def test_drop_while
    exec_asserts([100, 87, 5, 2], :drop_while) { |elem| elem < 50 }
    assert_kind_of MyEnumerator, @list.drop_while
  end

  def exec_asserts(exp, method, *args, &block)
    assert_all(exp, *get_results(exp, method, *args, &block))
  end

  def exec_refutes(exp, method, *args, &block)
    refute_all(exp, *get_results(exp, method, *args, &block))
  end

  def get_results(exp, method, *args, &block)
    # test direct method calling
    result1 = @list.send(method, *args, &block)

    # test via MyEnumerator#next
    enum = @list.to_my_enum(method, *args)
    result2 = begin
      enum.feed(block.call(enum.next)) while true
    rescue MyStopIteration
      $!.result
    end

    # test via MyEnumerator#each
    result3 = enum.each(&block)

    return result1, result2, result3
  end

  def assert_all(exp, *results)
    run_all(:assert, exp, *results)
  end

  def refute_all(exp, *results)
    run_all(:refute, exp, *results)
  end

  def run_all(type, exp, *results)
    results.each do |result|
      case exp
      when nil
        self.send("#{type}_nil", result)
      when Regexp
        self.send("#{type}_match", exp, result)
      when Class
        self.send("#{type}_kind_of", result)
      when []
        self.send("#{type}_empty", result)
      else
        self.send("#{type}_equal", exp, result)
      end
    end
  end
end
