defmodule Module1 do

  def fibonacci(n) do
    case n do
      0 -> 0
      1 -> 1
      _ -> fibonacci(n-1) + fibonacci(n-2)
    end
  end

  def factorial(n) do
    cond do
      # expr booleana -> código.
      # evalua la expresión y si es true, se ejecuta el código.
      # Si ninguna expresión se evalua a true, entonces el cond no hace nada.
      (n <= 1) -> 1
      true -> n*factorial(n-1)
    end
  end

  def random_probability(n) do
    k = :rand.uniform(n) #Enum.random(1..n) //Correcto.
    1 - (1 / k) #Calcular la probabilidad de que no salga un número desde 1 hasta k.
  end

  def digits(n) do
    #1023 // 1000 = 1, 1023 % 1000 != 023, 23.
    Module3.rev(aux_digits(n))
  end

  defp aux_digits(n) do
    if n in 0..9 do
      [n]
    else
      [rem(n, 10) | aux_digits(div(n, 10))]
    end
  end
end

defmodule Module2 do

  def test do
    #:ok Esto está mal.
    fn -> :ok end
  end

  def solve(a, b, n) do
    if is_prime_relative?(a, n) do
      rem(b*mult_inv(a, n), n)
    else
      :error
    end
  end

  defp mult_inv(a, n) do
    case egcd(a, n, 1, 0, 0, 1) do
      {_, x, _} ->
	if x <= 0 do
	  x + n
	else
	  x
	end
    end
  end

  defp egcd(o_r, r, o_s, s, o_t, t) do
    if r == 0 do
      {o_r, o_s, o_t}
    else
      quot = div(o_r, r)
      egcd(r, (o_r - quot*r), s, (o_s - quot*s), t, (o_t - quot*t))
    end
  end
  
  defp is_prime_relative?(x, y)  do
    if y == 0 do
      x == 1
    else
      is_prime_relative?(y, rem(x, y))
    end
  end
end

defmodule Module3 do

  def rev([]) do
    []
  end

  def rev([x | l]) do
    rev(l) ++ [x]
  end

  def sieve_of_erathostenes(n) do
    #Asumo que todos son primos, menos 0 y 1.
    #Empiezo a recorrer desde 2 hasta n digamos i.
    #Si criba[i] -> Marcar 2i, 3i, 4i... ki | ki < n (k+1)i > n como falso.
    #En otra pasada regresar todos los elementos i, tales que criba[i] es true.
    sieve = aux_sieve(Map.new(Enum.to_list(2..n), fn x -> {x, true} end), 2, n)
    Enum.filter(Map.keys(sieve), fn x -> Map.get(sieve, x) end)
  end

  defp aux_sieve(sieve, i, n) do
    cond do
      i > n -> sieve
      Map.get(sieve, i) -> aux_sieve(false_mark(sieve, i, 2, n), (i+1), n)
      true -> aux_sieve(sieve, (i+1), n)
    end
  end

  defp false_mark(sieve, i, k, n) do
    if i*k > n do
      sieve
    else
      false_mark(Map.put(sieve, i*k, false), i, (k+1), n)
    end
  end
  
  def elim_dup([]) do
    []
  end
  
  def elim_dup([x | l] ) do
    if Enum.member?(l, x) do
      [x | elim_dup(aux_elim(l, x))]
    else
      [x | elim_dup(l)]
    end
  end

  defp aux_elim(l, x) do
    if Enum.member?(l, x) do
      aux_elim(List.delete(l, x), x)
    else
      l
    end
  end
end

defmodule Module4 do

  def monstructure() do
    spawn(fn -> loop([], Map.new, MapSet.new, {}) end) #Regresa un PID, para intercambio de mensajes.
  end
  
  defp loop(list, map, ms, tuple) do
    receive do
      {:put_list, x} ->
	loop(list ++ [x], map, ms, tuple)
      {:get_list_size, caller} ->
	send(caller, {:list_size, Enum.count(list)})
	loop(list, map, ms, tuple)
      {:rem_list, x} ->
	loop(List.delete(list, x), map, ms, tuple)
      {:get_tuple, caller} ->
	send(caller, {:tuple_get, tuple})
	loop(list, map, ms, tuple)
      {:tup_to_list, caller} ->
	send(caller, {:tuple_as_list, Tuple.to_list(tuple)})
	loop(list, map, ms, tuple)
      {:put_tuple, x} ->
	loop(list, map, ms, Tuple.append(tuple, x))
      {:mapset_contains, x, caller} ->
	send(caller, {:contains_mapset, MapSet.member?(ms, x)})
	loop(list, map, ms, tuple)
      {:mapset_add, x} ->
	loop(list, map, MapSet.put(ms, x), tuple)
      {:mapset_size, caller} ->
	send(caller, {:size_mapset, Enum.count(ms)})
	loop(list, map, ms, tuple)
      {:map_put, k, v} ->
	loop(list, Map.put(map, k, v), ms, tuple)
      {:map_get, k, caller} ->
	send(caller, {:get_map, Map.get(map, k)})
	loop(list, map, ms, tuple)
      {:map_lambda, k, lambda, x} ->
	loop(list, Map.put(map, k, lambda.(Map.get(map, k), x)), ms, tuple)
      _ ->
	IO.puts("Operación incorrecta")
	loop(list, map, ms, tuple)
    end
  end
end
