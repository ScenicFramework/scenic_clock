# dynamically update the config to point to the test assets
Application.put_env(:scenic, :assets, module: Scenic.Clock.Test.Assets)
ExUnit.start()
