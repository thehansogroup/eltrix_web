defmodule EltrixSiteWeb.AssetsTest do
  @moduledoc """
  That the things the layout links actually exist.

  The site shipped to www.eltrix.org rendering in Times New Roman with blue
  underlined links, because removing Tailwind removed the only thing that
  copied CSS into `priv/static` — esbuild was building the JS and nothing was
  building the stylesheet. The layout linked `/assets/css/app.css` and the file
  was never written.

  Every test passed. The pages were correct, the claims were right, and the
  "no external requests" check greps for absolute URLs — a relative href to a
  file that does not exist is neither external nor present. Asserting that a
  page *renders* says nothing about whether it renders as anything.
  """
  use EltrixSiteWeb.ConnCase, async: true

  @static Path.expand("../../priv/static", __DIR__)

  test "every asset the layout links is on disk", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    paths =
      Regex.scan(~r/(?:href|src)="(\/assets\/[^"]+)"/, html)
      |> Enum.map(fn [_full, path] -> path end)

    assert paths != [], "the layout links no assets at all, which is itself suspicious"

    for path <- paths do
      file = Path.join(@static, path)
      assert File.exists?(file), "#{path} is linked by the layout and does not exist"
      assert File.stat!(file).size > 0, "#{path} exists and is empty"
    end
  end

  test "the stylesheet carries the design tokens, not just any bytes" do
    css = @static |> Path.join("assets/css/app.css") |> File.read!()

    # A stylesheet that built but lost its contents would pass the test above.
    # These are the nine custom properties the web client defines, which is what
    # makes this the same design language rather than a different one.
    for token <- ~w(--paper --sheet --ink --muted --hair --accent) do
      assert css =~ token, "the stylesheet is missing #{token}"
    end
  end
end
