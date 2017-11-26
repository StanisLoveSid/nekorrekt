require 'gruff'
include Math

class IncorrectnessSolving

  attr_accessor :n, :h, :eps, :alpha

  # first function value
  A_BIG = 1.00
  # last function value
  B_BIG = 2.00
  # boundaries of the integral
  A_SMALL = 0.00
  B_SMALL = 1.00
  F_V = [1.1216266444377032,
         1.326749744267982,
         1.6759427493101955,
         1.5567544929238246,
         1.4017043386292973,
         1.6133440801835377,
         1.2633294507084925,
         1.7546134946562288,
         1.5641484944927924]

  def initialize(n=10.0, h=0.14, eps=0.008, alpha=0)
    @n = n
    @h_small = h
    @h_big = (B_SMALL - A_SMALL) / n
    @eps = eps
    @alpha = alpha.to_f
    @collection_of_x_i = x_i_array_creation
    @function_values = []
    @simpson_optimized_for_output = []
    @array_history = []
  end

  def x_i_array_creation
    how_many = (0..@n.to_i).to_a
    how_many.map! {|i| (i*(@h_big + A_SMALL)) }
    duplicate = how_many
    duplicate.map!(&:to_s)
    new_arr = how_many.zip(duplicate)
    new_arr.to_h
  end

  def function_values_generation
    (@n.to_i).times { @function_values << rand(A_BIG..B_BIG)}
    @function_values.unshift A_BIG
    @function_values.push B_BIG
  end

  def making_graph
    @simpson_optimized_for_output
  end

  def creation_of_minimized_array
  	function_values_generation
    @array_history << @function_values
    until @h_small < @eps
      @h_small = @h_small/2
      k = 0
      minimized_array = []
      until next_array_equal_to_previous?(@array_history[k], @array_history[k-1], k)
        (1..(@n - 1)).to_a.each do |i|
          neutral = ((simpson_without_omega @array_history[k]) + (@alpha*(simpson_with_omega @array_history[k])))	
          plus_h = ((simpson_without_omega functional_values_plus_h(k, i)) + (@alpha*(simpson_with_omega functional_values_plus_h(k, i))))
          minus_h = ((simpson_without_omega functional_values_minus_h(k, i)) + (@alpha*(simpson_with_omega functional_values_minus_h(k, i))))
          search_for_min = []
          search_for_min << neutral
          search_for_min << plus_h
          search_for_min << minus_h
          found = search_for_min.min

          minimized_array << case found
          when neutral then @array_history[k][i]
          when plus_h then @array_history[k][i] + @h_small
          when minus_h then @array_history[k][i] - @h_small
          end
        end
        minimized_array.unshift A_BIG
        minimized_array.push B_BIG
        @array_history << minimized_array
        k += 1
      end
    end
    @array_history.last
  end

  def next_array_equal_to_previous?(new_array, old_array, i)
    if i != 0
      compared = old_array.zip(new_array).map {|x, y| x == y }
      compared.include? false ? false : true
    else
      false
    end
  end

  def simpson_without_omega(function_values)
    sum1 = A_BIG + B_BIG
    sum2 = 0
    @f_v = function_values

    (1..(@n.to_i - 1)).to_a.each do |i|
      sum2 += ((i % 2 == 1) ? 4 * @f_v[i] : 2 * @f_v[i])
    end

    res1 = (@h_big / 3) * (sum1 + sum2) - 1.25
    res1 * res1
  end

  def simpson_with_omega(function_values)
    v = A_BIG**2 + B_BIG**2
    first = function_values.shift
    last = function_values.pop
    function_values.each_with_index do |element, i|
      v += (i % 2 == 1) ? 4 * element * element : 2 * element * element
    end
    function_values.unshift first
    function_values.push last
    h = @h_big

    v *= (h / 3)

    dv = 0
    dv += ((function_values[1] - first) / h) *
    ((function_values[1] - first) / h)
    dv += ((last - function_values[@n - 1]) / h) *
    ((last - function_values[@n - 1]) / h)

    (1..(@n.to_i - 2)).to_a.each do |i|
      dv += (i % 2 == 1) ? 4 * ((function_values[i + 1] -
      function_values[i]) / (h)) * ((function_values[i+1] -
      function_values[i]) / (h)) : 2 * ((function_values[i+1] -
                                         function_values[i]) / (h)) * ((function_values[i+1] - function_values[i]) / (h))
    end

    dv *= (h / 3.0)
    v + dv
  end

  def excellent
    arr = []
    12.times {|i| arr << ((i**3) + 1)}
    arr
  end

  private

  def functional_values_plus_h(k, i)
    rememerable = @array_history[k][i] + @h_small
    @array_history[k].delete_at i
    @array_history[k].insert(i, (rememerable))
  end

  def functional_values_minus_h(k, i)
    rememerable = @array_history[k][i] - @h_small
    @array_history[k].delete_at i
    @array_history[k].insert(i, (rememerable))
  end

end

1.times do |alpha|
  g = Gruff::Line.new
  g.title = 'Wow!  Look at this!'
  g.labels = IncorrectnessSolving.new.x_i_array_creation
  g.data :Excellent, IncorrectnessSolving.new(10.0, 0.14, 0.008, 0.0042).creation_of_minimized_array
  g.write("an_ending.png")
end
