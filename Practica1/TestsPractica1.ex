require Module1
require Module2
require Module3
require Module4

ExUnit.start()

defmodule Tests do

  use ExUnit.Case, async: true

  test "fibonacci" do
    assert Module1.fibonacci(0) == 0
    assert Module1.fibonacci(1) == 1
    n = :rand.uniform(10)
    assert Module1.fibonacci(n) == (Module1.fibonacci(n-1) + Module1.fibonacci(n-2))
  end

  test "factorial" do
    assert Module1.factorial(0) == 1
    n = :rand.uniform(1000)
    assert Module1.factorial(n) == (n * Module1.factorial(n-1))
  end

  test "random_probability" do
    answer = Module1.random_probability(:rand.uniform(10000))
    assert 0 <= answer and answer <= 1
  end

  test "digits" do
    assert Module1.digits(0) == [0]
    assert Module1.digits(10) == [1, 0]
    assert Module1.digits(1023) == [1, 0, 2, 3]
    assert Module1.digits(1724) == [1, 7, 2, 4]
    random = :rand.uniform(10000)
    pow = :math.floor(:math.log10(random))
    assert Enum.count(Module1.digits(random)) == (pow+1)
  end

  test "ok_function" do
    assert Module2.test.() == :ok
  end


  test "solve_congruence" do
    assert Module2.solve(5, 11, 15) == :error #5x \equiv 10 mod 15, si tenía sol.
    assert Module2.solve(3, 2, 7) == 3
    assert Module2.solve(2, 1, 5) == 3
    assert Module2.solve(3, 8, 10) == 6
  end

  test "rev" do
    assert Module3.rev([]) == []
    assert Module3.rev([1, 2, 3]) == [3, 2, 1]
    l = [1, 2, 3]
    rev_l = Module3.rev(l)
    assert Module3.rev([3 | l]) == [3, 2, 1, 3]
  end

  test "sieve_of_erathostenes" do
    assert Module3.sieve_of_erathostenes(10) == [2, 3, 5, 7]
    assert Module3.sieve_of_erathostenes(20) == [2, 3, 5, 7, 11, 13, 17, 19]
    known_primes = [2131, 2293, 2437, 2621, 2749, 2909, 3083, 3259, 7727, 6841, 6481, 6311, 6143, 5953, 99371, 91193, 93719, 999331]
    p = Enum.random(known_primes)
    primes_til_p = Module3.sieve_of_erathostenes(p)
    Enum.each(known_primes, fn pp ->
      if pp <= p do
	assert Enum.member?(primes_til_p, pp)
      end
    end)
  end

  test "elim_dup" do
    assert Module3.elim_dup([1, 2, 3]) == [1, 2, 3]
    assert Module3.elim_dup([1, 1, 2, 2, 3, 3]) == [1, 2, 3]
    assert Module3.elim_dup([1, 2, 3, 1, 2, 3]) == [1, 2, 3]
    assert Module3.elim_dup([1, 2, 3, 3, 2, 1]) == [1, 2, 3]
  end

  test "mostructure" do
    monstr = Module4.monstructure() #Sé que inicialmente están vacías las EDDs
    # ---- INICIO DE PRUEBAS DE LISTAS ----- #
    send(monstr, {:put_list, 1})
    send(monstr, {:get_list_size, self()})
    assert reception() == 1
    send(monstr, {:rem_list, 2})
    send(monstr, {:get_list_size, self()})
    assert reception() == 1
    send(monstr, {:rem_list, 1})
    send(monstr, {:get_list_size, self()})
    assert reception() == 0
    # ---- FIN DE PRUEBAS DE LISTAS ---- #
    
    # ---- INICIO DE PRUEBAS DE TUPLAS ---- #
    send(monstr, {:get_tuple, self()})
    assert reception() == {}
    send(monstr, {:tup_to_list, self()})
    assert reception() == []
    send(monstr, {:put_tuple, 10})
    send(monstr, {:get_tuple, self()})
    assert reception() == {10}
    send(monstr, {:tup_to_list, self()})
    assert reception() == [10]
    # ---- FIN DE PRUEBAS DE TUPLAS ---- #

    # ---- INICIO DE PRUEBAS DE MAPSETS ----#
    send(monstr, {:mapset_contains, 10, self()})
    assert reception() == false
    send(monstr, {:mapset_add, 10})
    send(monstr, {:mapset_contains, 10, self()})
    assert reception()
    send(monstr, {:mapset_size, self()})
    assert reception() == 1
    # ---- FIN DE PRUEBAS DE MAPSETS ----#

    # ---- INICIO DE PRUEBAS DE MAPS ----#
    send(monstr, {:map_put, 1, 10})
    send(monstr, {:map_get, 1, self()})
    assert reception() == 10
    send(monstr, {:map_lambda, 1, (fn x, y -> x * y end), 20})#lambda.(params) 
    send(monstr, {:map_get, 1, self()})
    assert reception() == 200
    # ---- FIN DE PRUEBAS DE MAPS ----#
  end

  defp reception() do
    receive do
      {:list_size, x} -> x
      {:tuple_get, t} -> t
      {:tuple_as_list, l} -> l
      {:contains_mapset, b} -> b
      {:size_mapset, size} -> size
      {:get_map, v} -> v
      _ ->
	IO.puts("Mensaje desconocido")
	:error
    end
  end
end

    
