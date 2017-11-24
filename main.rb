require 'gruff'
include Math

class IncorrectnessSolving

  # first function value
  A_BIG = 1.00
  # last function value
  B_BIG = 2.00
  # boundaries of the integral
  A_SMALL = 0.00
  B_SMALL = 1.00
  @@array_history = []

  def initialize(n=10.0, h=0.14, eps=0.008, alpha=rand(0.0009..0.9))
    @n = n
    @h_small = h
    @h_big = (B_SMALL - A_SMALL) / n
    @eps = eps
    @alpha = alpha
    @collection_of_x_i = x_i_array_creation
    @function_values = []
    @simpson_optimized_for_output = []
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
    until @h_small < @eps
      @h_small = @h_small/2
      i = 0
      until next_array_equal_to_previous?(@@array_history[i], @@array_history[i-1], i)
        (1..(@n - 1)).to_a.each do |i|
          search_for_min = []
          search_for_min << ((simpson_without_omega @function_values) + (@alpha*(simpson_with_omega @function_values)))
          search_for_min << ((simpson_without_omega functional_values_plus_h(i)) + (@alpha*(simpson_with_omega functional_values_plus_h(i))))
          search_for_min << ((simpson_without_omega functional_values_minus_h(i)) + (@alpha*(simpson_with_omega functional_values_minus_h(i))))
          found = search_for_min.min

          @@array_history << case found
          when ((simpson_without_omega @function_values) + (@alpha*(simpson_with_omega @function_values))) then @simpson_optimized_for_output = @function_values
          when ((simpson_without_omega functional_values_plus_h(i)) + (@alpha*(simpson_with_omega functional_values_plus_h(i)))) then @simpson_optimized_for_output = functional_values_minus_h(i)
          when ((simpson_without_omega functional_values_minus_h(i)) + (@alpha*(simpson_with_omega functional_values_minus_h(i)))) then @simpson_optimized_for_output = functional_values_plus_h(i)
          end
        end
        i += 1
      end
    end
    
    making_graph
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

  private

  def functional_values_plus_h(i)
  	rememerable = @function_values[i] += @h_small
    @function_values.delete_at i
    @function_values.insert(i, (rememerable))
  end

  def functional_values_minus_h(i)
  	rememerable = @function_values[i] -= @h_small
    @function_values.delete_at i
    @function_values.insert(i, (rememerable))
  end

end

g = Gruff::Line.new
g.title = 'Wow!  Look at this!'


g.labels = IncorrectnessSolving.new.x_i_array_creation
g.data :Simpson, IncorrectnessSolving.new.creation_of_minimized_array
g.write("exciting#{rand(1.0..2000000.0)}.png")
