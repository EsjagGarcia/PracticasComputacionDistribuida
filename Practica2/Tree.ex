defmodule Tree do

  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
      {:broadcast, tree, i, caller} ->
        # Mandamos al proceso, su padre.
        send(self(), {:broadcast, caller})
        # Ejecutamos la función broadcast.
        broadcast(tree, i)
      {:convergecast, tree, i, caller} ->
        # Mandamos al proceso, su padre.
        send(self(), {:convergecast, caller})
        # Ejecutamos la función broadcast.
        convergecast(tree, i)
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
      # Guarda al padre.
      padre = recibeMensaje()
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
        # Mandamos a la raíz un mensaje indicando el proceso y que es hoja.
        send(Map.get(tree, 0), {self(), :hoja})
      end
      # Desde la raíz, va a recibir m mensajes, uno por cada hoja, y va a reenviarlos al proceso pricnipal.
      if Map.get(tree, node) == Map.get(tree, 0) do
        # Div, divide entre enteros, por lo que es como si hicieramos piso al resultado de la división.
        numHojas = div(n + 1,2)
        # Por cad hoja enviamos un mensaje al nodo principal.
        Enum.each(0..numHojas, fn _ -> recibeMensaje(padre) end)
      end
    end
    :terminado
  end

  @doc """
    Función auxiliar que espera a recibir al padre
  """
  def recibeMensaje() do
    receive do
      {:broadcast, caller} ->
        caller
      {:convergecast, caller} ->
        caller
    end

  end

  @doc """
    Función auxiliar que va a mandar al padre el mensaje recibido.

    Se usa para formar un ciclo y enviar mensajes por cada hoja.
  """
  def recibeMensaje(padre) do
    receive do
      {caller, :hoja} ->
        send(padre, {caller, :hoja})
    end

  end

  def convergecast(tree, n) do
    # Para simplificar y poder obtener de manera más fácil los hijos del árbol, debemos obtener la llave en el
    # Map que guarda el valor del PID.
    node = Enum.filter(0..n, fn x -> Map.get(tree, x) == self() end)
    # Caso inicial, si no encuentra que el proceso que esta invocando la función, significa que es el proceso
    # principal, por lo que inicializa. Mandando mensaje a todas las hojas.
    if node == [] do
      # Calcula el número de hojas el árbol. Sabiendo que, los últimos k nodos, son las k hojas, del árbol.
      numHojas = div(n + 1,2)
      numHojas = n - numHojas
      # Manda un mensaje a todas las hojas.
      Enum.each(numHojas..(n-1), fn x -> send(Map.get(tree, x), {:convergecast, tree, n, self()}) end)
    else
      # Guarda al padre (aquel nodo que le mando mensaje).
      antecesor = recibeMensaje()
      # Obtiene el valor del nodo.
      node = List.first(node)
      # El primer proceso en el Map, es la raíz la del árbol.
      if node == 0 do
        IO.puts("Soy #{inspect self()} y soy la raíz")
      else
        # Como nuestros árboles son binarios, y la forma de construirlos, implica que se forman de manera
        # ordenada (como si balancearamos), significa que todo nodo impar es hijo izquierdo, y todo nodo
        # par es hijo derecho.
        # Caso para el hijo izquierdo
        if rem(node,2) == 1 do
          # Encuentra su padre, usando un despeje de i, en la propiedad descrita en el documento.
          padre = div((node - 1),2)
          # Obitene el ID del proceso que es su padre.
          padre = Map.get(tree, padre)
          IO.puts("Soy #{inspect self()} y mi padre es #{inspect padre}")
          # Manda mensaje a su padre (en el árbol).
          send(padre, {:convergecast, tree, n, self()})
        end
        # Caso para el hijo derecho.
        if rem(node,2) == 0 do
          # Encuentra su padre, usando un despeje de i, en la propiedad descrita en el documento.
          padre = div((node - 2),2)
          # Obitene el ID del proceso que es su padre.
          padre = Map.get(tree, padre)
          IO.puts("Soy #{inspect self()} y mi padre es #{inspect padre}")
          # Manda mensaje a su padre (en el árbol).
          send(padre, {:convergecast, tree, n, self()})
        end
      end
    end
    :terminado
  end

end
