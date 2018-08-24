#
#  Created by Boyd Multerer on August 8, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

defmodule Scenic.Clock.Analog do
  @moduledoc """
  Documentation for ScenicSceneClock.
  """
  use Scenic.Component, has_children: false

  alias Scenic.Graph
  # alias Scenic.Component.Input.Dropdown
  import Scenic.Primitives,
    only: [
      {:circle, 3},
      {:line, 3},
      {:update_opts, 2}
    ]

  # import IEx

  # analog clock setup
  @default_radius 10
  @two_pi 2 * :math.pi()
  @back_size_ratio 0.1
  @hour_size_ratio -0.6
  @minute_size_ratio -0.9
  @second_size_ratio -0.9

  @default_timezone "GMT"

  # theme is {draw_color, background_color, second_hand_color}
  @themes %{
    light: {:black, :clear, :grey},
    dark: {:white, :clear, :grey}
  }
  @default_theme :dark

  # --------------------------------------------------------
  def verify(opts) when is_list(opts), do: {:ok, opts}
  def verify(_), do: :invalid_data

  # --------------------------------------------------------
  def init(opts, _args) do
    theme =
      case opts[:theme] do
        {_, _, _} = theme -> theme
        type -> Map.get(@themes, type) || Map.get(@themes, @default_theme)
      end

    {draw_color, background_color, second_color} = theme

    # confirm the timezone
    timezone =
      case Enum.member?(Timex.timezones(), opts[:timezone]) do
        true -> opts[:timezone]
        false -> Timex.Timezone.local() || @default_timezone
      end

    # get and calc the sizes 
    radius = opts[:size] || @default_radius
    back_size = radius * @back_size_ratio
    hour_size = radius * @hour_size_ratio
    minute_size = radius * @minute_size_ratio
    second_size = radius * @second_size_ratio

    thick =
      cond do
        radius > 40 -> 2
        true -> 1.2
      end

    # set up the requested graph
    graph =
      case !!opts[:seconds] do
        false ->
          Graph.build(t: {-radius, radius})
          |> circle(radius, fill: background_color, stroke: {thick, draw_color})
          |> line({{0, back_size}, {0, hour_size}},
            pin: {0, 0},
            stroke: {thick, draw_color},
            id: :hour_hand
          )
          |> line({{0, back_size}, {0, minute_size}},
            pin: {0, 0},
            stroke: {thick, draw_color},
            id: :minute_hand
          )

        true ->
          Graph.build(t: {-radius, radius})
          |> circle(radius, fill: background_color, stroke: {thick, draw_color})
          |> line({{0, back_size}, {0, hour_size}},
            pin: {0, 0},
            stroke: {thick, draw_color},
            id: :hour_hand
          )
          |> line({{0, back_size}, {0, minute_size}},
            pin: {0, 0},
            stroke: {thick, draw_color},
            id: :minute_hand
          )
          |> line({{0, back_size}, {0, second_size}},
            pin: {0, 0},
            stroke: {thick, second_color},
            id: :second_hand
          )
      end

    state =
      %{
        graph: graph,
        timezone: timezone,
        timer: nil,
        last: nil,
        seconds: !!opts[:seconds]
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
  defp update_time(
         %{
           graph: graph,
           timezone: timezone,
           seconds: seconds,
           last: last
         } = state
       ) do
    time = Timex.now(timezone)

    new_last =
      if seconds do
        time.second
      else
        time.minute
      end

    if new_last != last do
      # get the hour and minutes as a percent of the circle
      second_percent = time.second / 60.0

      # get the hour and minutes as a percent of the circle
      minute_percent = (time.minute + second_percent) / 60.0

      hour =
        cond do
          time.hour >= 12 -> time.hour - 12
          true -> time.hour
        end

      hour_percent = (hour + minute_percent) / 12.0

      # convert to radians and apply as a rotation matrix
      # a full circle is 2 radians...
      graph
      |> Graph.modify(:hour_hand, &update_opts(&1, r: @two_pi * hour_percent))
      |> Graph.modify(:minute_hand, &update_opts(&1, r: @two_pi * minute_percent))
      |> Graph.modify(:second_hand, &update_opts(&1, r: @two_pi * second_percent))
      |> push_graph()
    end

    %{state | last: new_last}
  end
end
