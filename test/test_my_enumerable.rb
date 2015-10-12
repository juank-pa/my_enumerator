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

  def exec_tests(exp, method, *args, &block)
    # test direct method calling
    result = @list.send(method, *args, &block)
    assert_equal exp, result

    # test via MyEnumerator#next
    enum = @list.to_my_enum(method, *args)
    begin
      enum.feed(block.call(enum.next)) while true
    rescue MyStopIteration
      assert_equal exp, $!.result
    end

    # test via MyEnumerator#each
    assert_equal exp, enum.each(&block)
  end

  def test_all?
    exec_tests(false, :all?) { |elem| elem.even? }
    exec_tests(true, :all?) { |elem| elem < 150 }
    assert_predicate @list, :all?
    refute_predicate @nil_list, :all?
  end

  def test_any?
    exec_tests(true, :any?) { |elem| elem.even? }
    exec_tests(false, :any?) { |elem| elem > 150 }
    assert_predicate @list, :any?
    assert_predicate @nil_list, :any?
  end

  def test_collect_or_map
    block = -> elem { elem * 5 }
    exp = @values.map(&block)
    exec_tests(exp, :map, &block)
    exec_tests(exp, :collect, &block)
  end

  def test_collect_concat
    block = -> elem { [elem * 5, [elem]] }
    exp = @values.collect_concat(&block)
    exec_tests(exp, :collect_concat, &block)
  end
end
