#
#  Created by Boyd Multerer on August 8, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#


defmodule Scenic.Clock.Digital do
  @moduledoc """
  Documentation for ScenicSceneClock.
  """
  use Scenic.Component, has_children: false

  alias Scenic.Graph
  alias Scenic.Primitive.Style.Theme


  # alias Scenic.Component.Input.Dropdown
  import Scenic.Primitives, only: [
    {:text, 2}, {:text, 3}, {:update_opts, 2}
  ]

  # import IEx

  # formats setup
  @formats %{
    day_time_12:    "%a %l:%M %p",
    day_time_12_s:  "%a %l:%M:%S %p",
    time_12:        "%l:%M %p",
    day_time_24:    "%a %l:%M",
    day_time_24_s:  "%a %l:%M:%S",
    time_24:        "%H:%M",
    time_24_s:      "%H:%M:%S",
  }
  @default_format   @formats[:day_time_12]

  @default_timezone "GMT"

  # theme
  @default_align      :right
  @default_font_size  20
  @default_font_blur  0
  @default_theme      :dark

  #--------------------------------------------------------
  def verify( opts ) when is_list(opts), do: {:ok, opts}
  def verify( _ ), do: :invalid_data

  #--------------------------------------------------------
  def init( opts, styles, _viewport ) do

    # theme is passed in as an inherited style
    theme = (styles[:theme] || Theme.preset(@default_theme))
    |> Theme.normalize()


    # get the formatting options
    align = opts[:align] || @default_align
    size = opts[:size] || @default_font_size

    # get the requested time format
    format =case opts[:format] do
      nil -> @default_format
      other -> @formats[other] || @default_format
    end

    # get the timezone
    timezone = case  Enum.member?(Timex.timezones(), opts[:timezone]) do
      true -> opts[:timezone]
      false -> Timex.Timezone.local() || @default_timezone
    end

    # set up the requested graph
    graph = Graph.build(font_size: size, t: {0, size})
    |> text("", fill: theme.text, id: :time, text_align: align)

    state = %{
      graph: graph,
      format: format,
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
    {microseconds,_} = Time.utc_now.microsecond
    Process.send_after(self(), :start_clock, 1001 - trunc(microseconds / 1000) )

    {:ok, state }
  end

  #--------------------------------------------------------
  # should be shortly after the actual one-second mark
  def handle_info( :start_clock, state ) do
    # start the timer on a one-second interval
    {:ok, timer} = :timer.send_interval(1000, :second)

    # update the clock
    state = update_time( state )

    {:noreply, %{state | timer: timer} }
  end

  #--------------------------------------------------------
  def handle_info( :second, state ) do
    {:noreply, update_time( state )}
  end

  #--------------------------------------------------------
  defp squash(string) do
    string
    |> String.trim
    |> String.replace(~r/\s{2,}/, " ")
  end

  #--------------------------------------------------------
  defp update_time( %{
    format: format,
    graph: graph,
    timezone: timezone,
    last: last
  } = state ) do
    {:ok, time} = Timex.now(timezone)
    |> Timex.format( format, :strftime )
    time = squash(time)

    if time != last do
      Graph.modify(graph, :time, &text(&1, time))
      |> push_graph()
    end

    %{state | last: time}
  end


end



















