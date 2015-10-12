require 'my_enumerator'
require 'test_classes'
require 'minitest/autorun'

class TestMyEnumerator < Minitest::Test
  def setup
    @obj    = create_test_object
    @args   = [:a, :x]
    @method = :each_arg
    @enum   = @obj.to_my_enum @method, *@args
  end

  def create_test_object
    Object.new.tap do |obj|
      def obj.each_arg(a, b=:b, *rest)
        yield
        yield nil
        yield a
        yield b, :test
        yield rest
        :method_returned
      end
    end
  end

  def test_create_enumerator_externally
    enum = MyEnumerator.new(@obj, @method, @args)
    assert_match /#@method/, enum.inspect
    assert_match /#{@args.map(&:inspect).join(', ')}/, enum.inspect
  end

  def test_create_enumerator_internally
    assert_match /#@method/, @enum.inspect
    assert_match /#{@args.map(&:inspect).join(', ')}/, @enum.inspect
  end

  def test_enumerators_created_with_object_and_method_are_not_generators
    refute_match /generator/i, @enum.inspect
  end

  def test_next_doesnt_difference_yielding_nil_vs_nothing
    assert_equal @enum.next, @enum.next
  end

  def test_next_values_differences_yielding_nil_vs_nothing
    val1, val2 = @enum.next_values, @enum.next_values
    refute_equal val1, val2
    assert_empty val1
    refute_empty val2
  end

  def test_enumeration_overflow_generates_exception_storing_returned_value
    exception = assert_raises(MyStopIteration) { @enum.next while true }
    assert_equal @obj.each_arg(*@args) {}, exception.result
  end

  def test_feeding_values_to_enumerators_affect_returned_value_on_overflow_exception
    obj = [1, 2, :a, :b]
    enum = obj.my_enum_for(:map)
    block = -> elem { "<#{elem.inspect}>" }

    begin
      while true
        val = enum.next
        enum.feed block.call(val)
      end
    rescue MyStopIteration
      assert_equal obj.map(&block), $!.result
    end
  end

  def test_each_returns_enumerated_method_results_when_given_a_block
    assert_equal @obj.each_arg(*@args) {}, @enum.each {}

    obj = [1, 2, :a, :b]
    enum = obj.my_enum_for(:map)
    block = -> elem { "<#{elem.inspect}>" }

    assert_equal obj.map(&block), enum.each(&block)
  end

  def test_next_values_enclose_arguments_as_array_except_if_multiple
    @enum.next; @enum.next
    next_values = @enum.peek_values
    next_obj = @enum.next

    assert_kind_of Array, next_values
    refute_kind_of Array, next_obj
    assert_equal next_obj, next_values.first

    next_values = @enum.peek_values
    next_obj = @enum.next

    assert_kind_of Array, next_values
    assert_equal next_values, next_obj
  end

  def test_loop_captures_my_stop_iteration_exception_and_breaks_out
    count = 0
    loop { (@enum.next; count += 1) while count < 20 }
    assert_equal 5, count
  end

  def test_sending_additional_arguments_to_each_appends_them_to_enumerated_method
    add_args = [1, 2, 3]
    enum = @enum.each(*add_args)
    4.times { enum.next }
    assert_equal add_args, enum.next
  end
end
