defmodule Tree do

  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
      {:broadcast, tree, i, caller} ->
        IO.puts("Hola #{inspect caller} soy #{inspect self()}")
        broadcast(tree, i)
        :ok
      {:convergecast, tree, i, caller} -> :ok #Aquí va su código.
    end
  end

  defp create_tree([], tree, _) do
    tree
  end

  defp create_tree([pid | l], tree, pos) do
    create_tree(l, Map.put(tree, pos, pid), (pos+1))
  end

  def broadcast(tree, n) do
    IO.puts("Soy #{inspect self()}")
    # Para simplificar y poder obtener de manera más fácil los hijos del árbol, debemos obtener la llave en el
    # Map que guarda el valor del PID.
    node = Enum.filter(0..n, fn x -> Map.get(tree, x) == self() end)
    # Caso inicial, si no encuentra que el proceso que esta invocando la función, es parte del árbol, llama a
    # la raíz.
    if node == [] do
      send(Map.get(tree, 0), {:broadcast, tree, n, self()})
    end
    :ok
  end

  def convergecast(tree, n) do
    #Aquí va su código.
    :ok
  end

end
