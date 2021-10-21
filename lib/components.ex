#
#  Created by Boyd Multerer April 30, 2018.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

# convenience functions for adding basic components to a graph.
# this module should be updated as new base components are added

defmodule Scenic.Clock.Components do
  alias Scenic.Graph
  alias Scenic.Primitive
  # alias Scenic.Primitive.SceneRef
  alias Scenic.Clock

  # import IEx

  @moduledoc """
  A set of helper functions to make it easy to add, or modify, clocks
  to a graph.
  """

  # --------------------------------------------------------
  @doc """
  Add an analog clock to a graph.

  There is no required data, only styles.

  ### Styles

  Analog Clocks honor the following styles

  * `:hidden` - If `false` the clock is rendered. If true, it is skipped. The default
    is `false`.
  * `:theme` - The color set used to draw. See below. The default is `:dark`

  ### Additional Options

  Analog clocks follow the following list of additional options.
  * `:radius` - the radius of the clock's main circle.
  * `:seconds` - `true` or `false`. Show the seconds hand. Note: Showing the seconds hand uses more energy by rendering the scene every second. The default is `false`.
  * `:ticks` - `true` or `false`. Show ticks marking the hour positions. Default is `true` if the radius is >= 30.


  ## Theme

  To pass in a custom theme, supply a map with at least the following entries:
  * `:border` - the color of the ring around the clock
  * `:background` - the normal background of the clock

  The following theme colors are optional. If they are not supplied, `:border` will be used.
  * `:hours` - the color of the hours hand
  * `:minutes` - the color of the minutes hand
  * `:seconds` - the color of the seconds hand


  ### Examples

  The following example creates an analog clock it on the screen.

      graph
      |> analog_clock( translate: {20, 20} )

  The next example makes the same clock as before, but shows the seconds hand.

      graph
      |> analog_clock( seconds: true, translate: {20, 20} )


  """
  @spec analog_clock(
          source :: Graph.t() | Primitive.t(),
          options :: list
        ) :: Graph.t() | Primitive.t()

  def analog_clock(graph, options \\ [])

  def analog_clock(%Graph{} = g, options) do
    add_to_graph(g, Clock.Analog, options)
  end

  def analog_clock(
        %Primitive{module: Primitive.Component, data: {Clock.Analog, _, _}} = p,
        options
      ) do
    modify(p, options)
  end

  # --------------------------------------------------------
  @doc """
  Add an digital clock to a graph.

  There is no required data, only configuration options.

  ### Styles

  Digital Clocks honors all the styles you would expect to render text.
  This includes
  * :font
  * :font_size
  * :text_align
  * :text_base

  Note that you must set the font/text styles directly on the component when
  you use it in a graph. They are not automatically inherited.

  ### Additional Options

  Digital clocks support the following list of options.
  * `:format` - `:hours_12` or `:hours_24`. The default is `:hours_12`.

  ## Theme

  The Digital clock does not use the current theme for coloring. Add a :fill style
  instead, just as you would for a text primitive.

  ### Examples

  The following example creates an analog clock it on the screen.

      graph
      |> digital_clock( translate: {20, 20} )


  """
  @spec digital_clock(
          source :: Graph.t() | Primitive.t(),
          options :: list
        ) :: Graph.t() | Primitive.t()

  def digital_clock(graph, options \\ [])

  def digital_clock(%Graph{} = g, options) do
    add_to_graph(g, Clock.Digital, options)
  end

  def digital_clock(
        %Primitive{module: Primitive.Component, data: {Clock.Digital, _, _}} = p,
        options
      ) do
    modify(p, options)
  end

  # ============================================================================
  # internal utilities

  defp add_to_graph(%Graph{} = g, mod, options) do
    mod.add_to_graph(g, nil, options)
  end

  defp modify(%Primitive{module: Primitive.Component, data: {mod, nil, id}} = p, options) do
    Primitive.put(p, {mod, nil, id}, options)
  end
end
