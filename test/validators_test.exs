#
#  Created by Boyd Multerer on 2019-03-23
#  Copyright © 2019-2021 Kry10 Limited
#

defmodule Scenic.Clock.ValidatorsTest do
  use ExUnit.Case, async: true

  alias Scenic.Clock.Analog
  alias Scenic.Clock.Digital

  test "digital validate passes valid data" do
    assert Digital.validate(nil) == {:ok, nil}
  end

  test "digital validate rejects initial value outside the extents" do
    {:error, msg} = Digital.validate(123)
    assert msg =~ "Invalid Scenic.Clock.Digital"
  end

  test "analog validate passes valid data" do
    assert Analog.validate(nil) == {:ok, nil}
  end

  test "analog validate rejects initial value outside the extents" do
    {:error, msg} = Analog.validate(123)
    assert msg =~ "Invalid Scenic.Clock.Analog"
  end
end
