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


  THESE DOCS NEED TO BE UPDATED
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
      |> analog_clock( seconds: true, translate: {20, 20} )


  """
  def analog_clock( graph, options \\ [] )

  def analog_clock( %Graph{} = g, options ) do
    add_to_graph( g, Clock.Analog, nil, options )
  end

  def analog_clock( %Primitive{module: Primitive.SceneRef} = p, options ) do
    modify( p, Clock.Analog, nil, options )
  end

 #--------------------------------------------------------
  @doc """
  Add an digital clock to a graph. There is no required data, only
  configuration options


  ### Options

  Digital clocks honor the following list of extra options.
  * `:timezone` - which timezone to display the time in. Should be one of the timezones supported by the Timex Hex package. See `Timex.timezones()`. The default is whatever Timex sais is the system timexone.
  * `:format` - strftime format for the time string. Default is `"%a %l:%M %p"`.

  For help building a strftime format, see [https://foragoodstrftime.com/](https://foragoodstrftime.com/).


  ### Styles

  Digital Clocks honors all the styles you would expect to render text.
  

  ## Theme

  The Digital clock does not use the current theme for coloring. Add a :fill style
  instead, just as you would for a text primitive.

  ### Examples

  The following example creates an analog clock it on the screen.

      graph
      |> digital_clock( translate: {20, 20} )


  """
  def digital_clock( graph, options \\ [] )

  def digital_clock( %Graph{} = g, options ) do
    add_to_graph( g, Clock.Digital, nil, options )
  end

  def digital_clock( %Primitive{module: Primitive.SceneRef} = p, options ) do
    modify( p, Clock.Digital, nil, options )
  end

  #============================================================================
  # internal utilities

  defp add_to_graph( %Graph{} = g, mod, data, options ) do
    mod.verify!(data)
    mod.add_to_graph(g, data, options)
  end

  defp modify( %Primitive{module: Primitive.SceneRef} = p, mod, data, options ) do
    mod.verify!(data)
    Primitive.put( p, {mod, data}, options )
  end


end






