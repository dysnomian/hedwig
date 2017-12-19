defmodule Hedwig.Reaction do
  @moduledoc """
  Hedwig Reaction
  """

  @type matches   :: list | map
  @type name      :: binary
  @type private   :: map
  @type ref       :: reference
  @type robot     :: pid
  @type room      :: binary
  @type timestamp :: binary
  @type type      :: binary
  @type user      :: Hedwig.User.t

  @type t :: %__MODULE__{
    matches:   matches,
    name:      name,
    private:   private,
    ref:       ref,
    robot:     robot,
    room:      room,
    timestamp: timestamp,
    type:      type,
    user:      user
  }

  defstruct matches:   nil,
            name:      nil,
            private:   %{},
            ref:       nil,
            robot:     nil,
            room:      nil,
            timestamp: nil,
            type:      nil,
            user:      %Hedwig.User{}
end
