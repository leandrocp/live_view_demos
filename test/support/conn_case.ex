defmodule LiveViewDemosWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint LiveViewDemosWeb.Endpoint

      use LiveViewDemosWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import LiveViewDemosWeb.ConnCase
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
