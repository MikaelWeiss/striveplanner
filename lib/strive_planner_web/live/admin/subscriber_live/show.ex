defmodule StrivePlannerWeb.Admin.SubscriberLive.Show do
  use StrivePlannerWeb, :live_view

  alias StrivePlanner.Newsletter

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:subscriber, Newsletter.get_subscriber!(id))}
  end

  defp page_title(:show), do: "Show Subscriber"
  defp page_title(:edit), do: "Edit Subscriber"

  @impl true
  def handle_info(
        {StrivePlannerWeb.Admin.SubscriberLive.FormComponent, {:saved, subscriber}},
        socket
      ) do
    {:noreply, assign(socket, :subscriber, subscriber)}
  end
end
