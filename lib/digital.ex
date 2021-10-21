#
#  Created by Boyd Multerer on August 8, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

defmodule Scenic.Clock.Digital do
  @moduledoc """
  A component that runs an digital clock.

  See the [Components](Scenic.Clock.Components.html#digital_clock/2) module for usage


  """
  use Scenic.Component, has_children: false

  alias Scenic.Graph
  import Scenic.Primitives, only: [{:text, 2}, {:text, 3}]

  # formats setup
  @default_format :hours_12

  # --------------------------------------------------------
  @doc false
  @impl Scenic.Component
  def validate(nil), do: {:ok, nil}

  def validate(data) do
    {
      :error,
      """
      #{IO.ANSI.red()}Invalid Scenic.Clock.Digital
      Received: #{inspect(data)}
      #{IO.ANSI.yellow()}
      """
    }
  end

  # --------------------------------------------------------
  @doc false
  @impl Scenic.Scene
  def init(scene, _param, opts) do
    styles = Keyword.get(opts, :styles, [])

    format =
      case opts[:format] do
        :hours_12 -> :hours_12
        :hours_24 -> :hours_24
        _ -> @default_format
      end

    # set up the requested graph
    graph =
      Graph.build(styles)
      |> text("", id: :time)

    scene =
      scene
      |> assign(
        graph: graph,
        format: format,
        seconds: !!opts[:seconds]
      )
      |> assign_new(timer: nil, last: nil)
      |> update_time()

    # send a message to self to start the clock a fraction of a second
    # into the future to hopefully line it up closer to when the seconds
    # actually are. Note that I want it to arrive just slightly after
    # the one second mark, which is way better than just slighty before.
    # avoid trunc errors and such that way even if it means the second
    # timer is one millisecond behind the actual time.
    {microseconds, _} = Time.utc_now().microsecond
    Process.send_after(self(), :start_clock, 1001 - trunc(microseconds / 1000))

    {:ok, scene}
  end

  # --------------------------------------------------------
  @doc false
  # should be shortly after the actual one-second mark
  @impl GenServer
  def handle_info(:start_clock, scene) do
    # start the timer on a one-second interval
    {:ok, timer} = :timer.send_interval(1000, :tick_tock)

    scene =
      scene
      |> assign(:timer, timer)
      |> update_time()

    # update the clock
    {:noreply, scene}
  end

  # --------------------------------------------------------
  def handle_info(:tick_tock, scene) do
    {:noreply, update_time(scene)}
  end

  # --------------------------------------------------------
  defp update_time(
         %{
           assigns: %{
             format: format,
             seconds: seconds,
             graph: graph,
             last: last
           }
         } = scene
       ) do
    time = :calendar.local_time()
    base_time = base_time(time, seconds)

    case base_time != last do
      true ->
        graph = Graph.modify(graph, :time, &text(&1, format_time(time, format, seconds)))

        scene
        |> assign(last: base_time, graph: graph)
        |> push_graph(graph)

      _ ->
        scene
    end
  end

  # --------------------------------------------------------
  defp format_time({_, {h, m, s}}, :hours_12, seconds) do
    {h, am_pm} =
      cond do
        h > 12 -> {h - 12, "PM"}
        true -> {h, "AM"}
      end

    case seconds do
      true -> "#{h}:#{format_ms(m)}:#{format_ms(s)} #{am_pm}"
      false -> "#{h}:#{format_ms(m)} #{am_pm}"
    end
  end

  defp format_time({_, {h, m, s}}, :hours_24, seconds) do
    case seconds do
      true -> "#{h}:#{format_ms(m)}:#{format_ms(s)}"
      false -> "#{h}:#{format_ms(m)}"
    end
  end

  defp format_ms(m) when m >= 0 and m < 10, do: "0#{m}"
  defp format_ms(m), do: to_string(m)

  # --------------------------------------------------------
  defp base_time(time, true), do: time
  defp base_time({d, {h, m, _}}, false), do: {d, {h, m}}
end
