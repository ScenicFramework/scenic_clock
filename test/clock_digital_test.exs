#
#  Created by Boyd Multerer on 23/03/2019.
#  Copyright © 2019 Kry10 Industries. All rights reserved.
#

defmodule Scenic.Clock.DigitalTest do
  use ExUnit.Case, async: true
  doctest Scenic.Scenes.Error

  @state %{
    graph: Scenic.Graph.build(),
    format: :hours_12,
    timer: nil,
    last: nil,
    seconds: true
  }

  test "init" do
    {:ok, _, push: _} =
      Scenic.Clock.Analog.init( nil, styles: %{} )
  end

  test "handle_info start_clock" do
    {:noreply, state, push: _} = Scenic.Clock.Analog.handle_info( :start_clock, @state )
    assert state.timer
  end

  test "handle_info tick_tock" do
    {:noreply, _, push: _} = Scenic.Clock.Analog.handle_info( :start_clock, @state )
  end

end
