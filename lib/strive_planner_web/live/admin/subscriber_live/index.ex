defmodule StrivePlannerWeb.Admin.SubscriberLive.Index do
  use StrivePlannerWeb, :live_view

  alias StrivePlanner.Newsletter
  alias StrivePlanner.Newsletter.Subscriber

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :subscribers, Newsletter.list_subscribers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Subscriber")
    |> assign(:subscriber, Newsletter.get_subscriber!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subscriber")
    |> assign(:subscriber, %Subscriber{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subscribers")
    |> assign(:subscriber, nil)
  end

  @impl true
  def handle_info(
        {StrivePlannerWeb.Admin.SubscriberLive.FormComponent, {:saved, subscriber}},
        socket
      ) do
    {:noreply, stream_insert(socket, :subscribers, subscriber)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subscriber = Newsletter.get_subscriber!(id)
    {:ok, _} = Newsletter.delete_subscriber(subscriber)

    {:noreply, stream_delete(socket, :subscribers, subscriber)}
  end

  @impl true
  def handle_event("cancel_modal_close", _, socket) do
    {:noreply, socket}
  end
end
