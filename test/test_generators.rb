require 'my_enumerator'
require 'minitest/autorun'

class TestGenerators < Minitest::Test
  def setup
    @size = Float::INFINITY
    @fib  = create_generator_with MyEnumerator, @size, :yield
  end

  def create_generator_with(cls, size, operator)
    # fibonacci series
    cls.new(@size) do |yielder|
      f1, f2 = 1, 1
      loop do
        yielder.send(operator, f1)
        f1, f2 = f2, f1 + f2
      end
    end
  end

  def test_enumerators_are_generators_with_a_block
    assert_instance_of MyEnumerator, @fib
    assert_match /generator/i, @fib.inspect
  end

  def test_next_returns_the_next_fibonacci_value
    f1, f2 = @fib.next, @fib.next

    10.times do
      assert_equal f1 + f2, @fib.next
      f1, f2 = f2, f1 + f2
    end
  end

  def test_you_can_rewind_generators
    first_value = @fib.next
    4.times { @fib.next }

    refute_equal first_value, @fib.next
    @fib.rewind
    assert_equal first_value, @fib.next
  end

  def test_you_can_peek_a_value_without_moving_next
    prev_value, value = nil
    4.times { prev_value = @fib.next }
    4.times { value = @fib.peek }

    refute_equal prev_value, value
    assert_equal value, @fib.peek
  end

  def test_you_can_set_a_lazy_size_in_generators
    assert_equal @size, @fib.size
  end

  def test_an_index_can_be_added_to_the_sequence
    counter = -1
    @fib.each_with_index do |fb, index|
      assert_equal (counter += 1), index
      break if index == 5
    end

    counter = 4
    @fib.with_index(counter) do |fb, index|
      assert_equal counter, index
      counter += 1
      break if index == 5
    end
  end

  def test_an_object_can_be_added_to_the_sequence
    sent_obj, counter = Object.new, -1
    @fib.each_with_object(sent_obj) do |fb, obj|
      assert_equal sent_obj, obj
      break if (counter += 1) == 5
    end
  end

  def test_calling_iterators_without_arguments_return_enumerators
    enum = @fib.each_with_index
    assert_instance_of MyEnumerator, enum
    refute_equal enum, @fib

    enum = @fib.each_with_object(Object.new)
    assert_instance_of MyEnumerator, enum
    refute_equal enum, @fib

    enum = @fib.each
    assert_instance_of MyEnumerator, enum
    assert_equal enum, @fib
    enum = @fib.each(1, 2, 3)
    refute_equal enum, @fib
  end

  def test_yield_operator
    @fib2 = create_generator_with MyEnumerator, @size, :<<
    assert_equal 1, @fib2.next
  end
end
