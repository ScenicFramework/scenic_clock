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


  #--------------------------------------------------------
  @doc """
  Add an analog clock to a graph. There is no required data, only
  configuration options


  ### Options

  Analog clocks honor the following list of extra options.
  * `:radius` - the radius of the clock's main circle.
  * `:timezone` - which timezone to display the time in. Should be one of the timezones supported by the Timex Hex package. See `Timex.timezones()`. The default is whatever Timex says is the system timezone.
  * `:seconds` - `true` or `false`. Show the seconds hand. Note: Showing the seconds hand uses more energy by rendering the scene every second. The default is `false`.
  * `:ticks` - `true` or `false`. Show ticks marking the hour positions. Default is `true` if the radius is >= 30.


  ### Styles

  Analog Clocks honor the following styles
  
  * `:hidden` - If `false` the clock is rendered. If true, it is skipped. The default
    is `false`.
  * `:theme` - The color set used to draw. See below. The default is `:dark`

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
      |> analog_clock( [seconds: true], translate: {20, 20} )


  """
  def analog_clock( graph, options \\ [] )

  def analog_clock( %Graph{} = g, options ) do

    {component_opts, standard_opts} = {[], options}
    |> extract_option( :radius )
    |> extract_option( :timezone )
    |> extract_option( :seconds )
    |> extract_option( :ticks )

    add_to_graph( g, Clock.Analog, component_opts, standard_opts )
  end

  def analog_clock( %Primitive{module: Primitive.SceneRef} = p, options ) do
    {component_opts, standard_opts} = {[], options}
    |> extract_option( :radius )
    |> extract_option( :timezone )
    |> extract_option( :seconds )
    |> extract_option( :ticks )

    modify( p, Component.Analog, component_opts, standard_opts )
  end

 #--------------------------------------------------------
  @doc """
  Add an digital clock to a graph. There is no required data, only
  configuration options


  ### Options

  Digital clocks honor the following list of extra options.
  * `:timezone` - which timezone to display the time in. Should be one of the timezones supported by the Timex Hex package. See `Timex.timezones()`. The default is whatever Timex sais is the system timexone.
  * `:seconds` - true or false. Show the seconds hand. Note: Showing the seconds hand uses more energy by rendering the scene every second. The default is `false`.


  ### Styles

  Digital Clocks honor the following styles
  
  * `:font` - The font to render the clock in. The default is `:roboto`
  * `:font_size` - The font size of the clock. The default is `20`
  * `:font_blur` - defaults to no blur
  * `:text_align` - defaults to `:right`
  * `:hidden` - If `false` the clock is rendered. If `true`, it is skipped. The default
    is `false`.
  * `:theme` - The color set used to draw. See below. The default is `:dark`

  ## Theme

  To pass in a custom theme, supply a map with at least the following entries:
  * `:text` - the color of the clock text

  ### Examples

  The following example creates an analog clock it on the screen.

      graph
      |> digital_clock( translate: {20, 20} )

  The next example makes the same clock as before, but shows the seconds hand.

      graph
      |> digital_clock( [seconds: true], translate: {20, 20} )


  """
  def digital_clock( graph, options \\ [] )

  def digital_clock( %Graph{} = g, options ) do

    {component_opts, standard_opts} = {[], options}
    |> extract_option( :timezone )
    |> extract_option( :seconds )

    add_to_graph( g, Clock.Digital, component_opts, standard_opts )
  end

  def digital_clock( %Primitive{module: Primitive.SceneRef} = p, options ) do
    {component_opts, standard_opts} = {[], options}
    |> extract_option( :timezone )
    |> extract_option( :seconds )

    modify( p, Component.Digital, component_opts, standard_opts )
  end

  #============================================================================
  # internal utilities

  defp extract_option( {options, source}, key ) do
    case Keyword.fetch(source, key) do
      {:ok, value} ->
        {
          [ {key, value} | options ],
          Enum.reject(source, fn({k,_}) -> k == key end)
        }
      _ ->
        {options, source}
    end
  end

  defp add_to_graph( %Graph{} = g, mod, data, options ) do
    mod.verify!(data)
    mod.add_to_graph(g, data, options)
  end

  defp modify( %Primitive{module: Primitive.SceneRef} = p, mod, data, options ) do
    mod.verify!(data)
    Primitive.put( p, {mod, data}, options )
  end


end






