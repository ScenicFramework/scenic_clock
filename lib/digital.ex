#
#  Created by Boyd Multerer on August 8, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

defmodule Scenic.Clock.Digital do
  @moduledoc """
  A component that runs an digital clock.

  See the [Components](Scenic.Clock.Components.html#digital_clock/2) module for useage


  """
  use Scenic.Component, has_children: false

  alias Scenic.Graph
  # alias Scenic.Primitive.Style.Theme

  # alias Scenic.Component.Input.Dropdown
  import Scenic.Primitives, only: [{:text, 2}, {:text, 3}]

  # import IEx

  # formats setup
  @default_format "%a %l:%M %p"

  @default_timezone "GMT"

  # theme
  # @default_theme    :dark

  # --------------------------------------------------------
  @doc false
  def verify(nil), do: {:ok, nil}
  def verify(_), do: :invalid_data

  # --------------------------------------------------------
  @doc false
  def init(_, opts) do
    styles = opts[:styles]

    # get the timezone
    timezone =
      case Enum.member?(Timex.timezones(), styles[:timezone]) do
        true -> styles[:timezone]
        false -> Timex.Timezone.local() || @default_timezone
      end

    # get and validate the requested time format
    format =
      case styles[:format] do
        format when is_bitstring(format) ->
          # doubleck check that is is a valid
          Timex.now(timezone)
          |> Timex.format(format, :strftime)
          |> case do
            {:ok, _} -> format
            _ -> @default_format
          end

        _ ->
          @default_format
      end

    # set up the requested graph
    graph =
      Graph.build(styles: styles)
      # |> text("", fill: theme.text, id: :time)
      |> text("", id: :time)

    state =
      %{
        graph: graph,
        format: format,
        timezone: timezone,
        timer: nil,
        last: nil,
        seconds: !!styles[:seconds]
      }
      # start up the graph
      |> update_time()

    # send a message to self to start the clock a fraction of a second
    # into the future to hopefully line it up closer to when the seconds
    # actually are. Note that I want it to arrive just slightly after
    # the one second mark, which is way better than just slighty before.
    # avoid trunc errors and such that way even if it means the second
    # timer is one millisecond behind the actual time.
    {microseconds, _} = Time.utc_now().microsecond
    Process.send_after(self(), :start_clock, 1001 - trunc(microseconds / 1000))

    {:ok, state}
  end

  # --------------------------------------------------------
  @doc false
  # should be shortly after the actual one-second mark
  def handle_info(:start_clock, state) do
    # start the timer on a one-second interval
    {:ok, timer} = :timer.send_interval(1000, :second)

    # update the clock
    state = update_time(state)

    {:noreply, %{state | timer: timer}}
  end

  # --------------------------------------------------------
  def handle_info(:second, state) do
    {:noreply, update_time(state)}
  end

  # --------------------------------------------------------
  defp squash(string) do
    string
    |> String.trim()
    |> String.replace(~r/\s{2,}/, " ")
  end

  # --------------------------------------------------------
  defp update_time(
         %{
           format: format,
           graph: graph,
           timezone: timezone,
           last: last
         } = state
       ) do
    {:ok, time} =
      Timex.now(timezone)
      |> Timex.format(format, :strftime)

    time = squash(time)

    if time != last do
      Graph.modify(graph, :time, &text(&1, time))
      |> push_graph()
    end

    %{state | last: time}
  end
end
