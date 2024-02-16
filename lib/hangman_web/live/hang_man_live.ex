defmodule HangmanWeb.HangmanLive do
  use HangmanWeb, :live_view

  def mount(_params, _session, socket) do
    random_word = Enum.random(["WORD", "OTHERWORD"]) |> String.graphemes()

    socket =
      socket
      |> assign(:word, random_word)
      |> assign(:guessed_correct, [])
      |> assign(:guessed_wrong, [])

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="confetti" phx-hook="WonHangman"></div>
    <h1 class="current-word">
      <%= for let <- @word do %>
        <%= if(Enum.member?(assigns.guessed_correct, let)) do %>
          <%= let %>
        <% else %>
          _
        <% end %>
      <% end %>
    </h1>

    <div id="galg">
      <%= for num <- 0..min(11,length(@guessed_wrong)) do %>
        <div class="hang-part" id={"part#{num}"}></div>
      <% end %>
    </div>

    <div class="content-start">
      <%= for letter <- Enum.map(?A..?Z, fn(x) -> <<x :: utf8>> end) do %>
        <%= if Enum.member?(assigns.guessed_wrong, letter) do %>
          <button class="btn btn-red" phx-click="choice_made" phx-value-letter={letter}>
            <%= letter %>
          </button>
        <% else %>
          <%= if Enum.member?(assigns.guessed_correct, letter) do %>
            <button class="btn btn-green" phx-click="choice_made" phx-value-letter={letter}>
              <%= letter %>
            </button>
          <% else %>
            <button class="btn" phx-click="choice_made" phx-value-letter={letter}>
              <%= letter %>
            </button>
          <% end %>
        <% end %>
      <% end %>
    </div>
    """
  end

  def handle_event("choice_made", %{"letter" => letter}, socket) do
    socket =
      if Enum.member?(socket.assigns.guessed_correct, letter) or
           Enum.member?(socket.assigns.guessed_wrong, letter) do
        socket
      else
        if Enum.member?(socket.assigns.word, letter) do
          update(socket, :guessed_correct, fn x -> [letter | x] end)
          |> check_win()
        else
          update(socket, :guessed_wrong, fn x -> [letter | x] end)
        end
      end

    {:noreply, socket}
  end

  def handle_event("choice_made", _, socket) do
    IO.puts("invalid guess")
    {:noreply, socket}
  end

  defp check_win(socket) do
    if socket.assigns.word
       |> Enum.filter(fn x -> not Enum.member?(socket.assigns.guessed_correct, x) end)
       |> Enum.count() == 0 do
      socket |> push_event("won", %{})
    else
      socket
    end
  end
end
