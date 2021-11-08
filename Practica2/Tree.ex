defmodule Tree do

  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
      {:broadcast, tree, i, caller} ->
        broadcast(tree, i)
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
    # Para simplificar y poder obtener de manera más fácil los hijos del árbol, debemos obtener la llave en el
    # Map que guarda el valor del PID.
    node = Enum.filter(0..n, fn x -> Map.get(tree, x) == self() end)
    # Caso inicial, si no encuentra que el proceso que esta invocando la función, es parte del árbol, llama a
    # la raíz.
    if node == [] do
      send(Map.get(tree, 0), {:broadcast, tree, n, self()})
    else
      # Obtiene el valor del nodo.
      node = List.first(node)
      # Obtiene el indice que se corresponde al hijo izquierdo.
      hijoI = (2 * node) + 1
      # Verifica que tenga hijo izquierdo.
      if hijoI < n do
        # Obtiene el proceso que se corresponde al hijo izquierdo.
        hijoI = Map.get(tree, hijoI)
        # Le manda mensaje a su hijo izquierdo.
        send(hijoI, {:broadcast, tree, n, self()})
      end
      # Obtiene el indice que se corresponde al hijo derecho.
      hijoD = (2 * node) + 2
      # Verifica que tenga hijo derecho.
      if hijoD < n do
        # Obtiene el proceso que se corresponde al hijo derecho.
        hijoD = Map.get(tree, hijoD)
        # Le manda mensaje a su hijo derecho.
        send(hijoD, {:broadcast, tree, n, self()})
      end
      # Si no tuvo ni hijo izquierdo, ni hijo derecho, significa que es hoja.
      if hijoD >= n && hijoI >= n do
        IO.puts("El nodo #{inspect node} con proceso #{inspect self()} es hoja.")
      end
    end
    :ok
  end

  def convergecast(tree, n) do
    #Aquí va su código.
    :ok
  end

end
