require Consensus

defmodule ConsensusTests do

  test "Consenso" do
    processes = Consensus.create_consensus(10)
    Consensus.consensus(processes) #Esto ya lo va a dormir un rato.
    values = Enum.map(processes, fn pid ->
      send(pid, {:get_value, self()})
      receive do
	x -> x
      after
	1000 -> :ok
      end
    end)
    values = Enum.filter(values, fn x -> x != :ok end)
    first = Enum.at(values, 0)
    Enum.each(values, fn x ->
      assert x == first
    end)
  end

end
