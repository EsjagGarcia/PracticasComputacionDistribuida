defmodule Graph do

  def new(n) do
    create_graph(Enum.map(1..n, fn _ -> spawn(fn -> loop(-1) end) end), %{}, n)
  end

  defp loop(state) do
    receive do
      {:bfs, graph, new_state} ->
        state = cond do
          state == -1 || new_state < state -> new_state
          true -> state
        end
        Enum.map(Map.get(graph, self()), fn x -> send(x, {:bfs, graph, state+1})end)
        loop(state)

      {:dfs, graph, new_state} ->
        state = cond do
          state == -1 || new_state < state -> new_state
          true -> state
        end
        nodo = Enum.random(Map.get(graph, self()))
        Enum.map(Map.get(graph, self()), fn x -> send(x, {:dfs, graph, state+1})end)
        graph = Map.put(graph, self(), Map.delete(Map.get(graph, self()), nodo))
        loop(state)

      {:get_state, caller} -> #Estos mensajes solo los manda el main.
        if state == -1 do
          Process.sleep(5000)
          send(self(), {:get_state, caller})
          loop(state)
        else
          send(caller, {self(), state})
        end
    end
  end

  defp create_graph([], graph, _) do
    graph
  end

  defp create_graph([pid | l], graph, n) do
    g = create_graph(l, Map.put(graph, pid, MapSet.new()), n)
    e = :rand.uniform(div(n*(n-1), 2))
    create_edges(g, e)
  end

  defp create_edges(graph, 0) do
    graph
  end

  defp create_edges(graph, n) do
    nodes = Map.keys(graph)
    create_edges(add_edge(graph, Enum.random(nodes), Enum.random(nodes)), n-1)
  end

  defp add_edge(graph, u, v) do
    cond do
      u == nil or v == nil -> graph
      u == v -> graph
      true ->
	u_neighs = Map.get(graph, u)
	new_u_neighs = MapSet.put(u_neighs, v)
	graph = Map.put(graph, u, new_u_neighs)
	v_neighs = Map.get(graph, v)
	new_v_neighs = MapSet.put(v_neighs, u)
	Map.put(graph, v, new_v_neighs)
    end
  end

  def random_src(graph) do
    Enum.random(Map.keys(graph))
  end

  def bfs(graph, src) do
    send(src, {:bfs, graph, 0})
    estados(Map.keys(graph), map_size(graph), 0)
    Enum.map(Map.keys(graph), fn x -> send(x,{:get_state,self()})
      receive do
        x -> x
      end
    end)
  end

  def bfs(graph) do
    bfs(graph, random_src(graph))
  end

  def dfs(graph, src) do
    send(src, {:dfs, graph, 0})
    estados(Map.keys(graph), map_size(graph), 0)
    Enum.map(Map.keys(graph), fn x -> send(x,{:get_state,self()})
      receive do
        x -> x
      end
    end)
  end

  def dfs(graph) do
    dfs(graph, random_src(graph))
  end

  @doc """
    Función auxiliar que obtiene los estados de los nodos.

    Obtiene los estados de los nodos de manera recursiva.
  """
  def estados(nodos, size, distancia) do
    if distancia < size do
      send(Enum.at(nodos, distancia), {:get_state, self()})
      estados(nodos, size, distancia+1)
    end
  end

end
