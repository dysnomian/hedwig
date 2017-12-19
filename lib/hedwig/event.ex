defmodule Hedwig.Event do
  @moduledoc """
  Hedwig Event
  """

  @type room      :: binary
  @type text      :: binary
  @type timestamp :: binary
  @type type      :: binary
  @type user      :: Hedwig.User.t

  @type t :: %__MODULE__{
    room:      room,
    text:      text,
    timestamp: timestamp,
    type:      type,
    user:      user
  }

  defstruct room:      nil,
            text:      nil,
            timestamp: nil,
            type:      nil,
            user:      %Hedwig.User{}
end
