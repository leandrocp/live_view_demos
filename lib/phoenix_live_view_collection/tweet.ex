defmodule LiveViewCollection.Tweet do
  @type t :: %__MODULE__{
          id: String.t(),
          url: String.t(),
          html: String.t()
        }

  defstruct [:id, :url, :html]
end
