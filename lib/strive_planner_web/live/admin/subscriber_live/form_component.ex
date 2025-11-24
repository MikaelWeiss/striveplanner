defmodule StrivePlannerWeb.Admin.SubscriberLive.FormComponent do
  use StrivePlannerWeb, :live_component

  alias StrivePlanner.Newsletter
  alias StrivePlanner.Email

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative">
      <!-- Header with X button -->
      <div class="flex items-center justify-between p-6 border-b border-white/10">
        <h2 class="text-xl font-medium text-white">{@title}</h2>
        <.link
          patch={@patch}
          class="text-gray-400 hover:text-white transition-colors"
        >
          <.icon name="hero-x-mark" class="w-6 h-6" />
        </.link>
      </div>

      <.form
        for={@form}
        id="subscriber-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="p-6 space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Email
            </label>
            <.input
              field={@form[:email]}
              type="email"
              class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
            />
          </div>

          <div class="flex items-center gap-3">
            <.input
              field={@form[:verified]}
              type="checkbox"
              class="w-5 h-5 bg-white/5 border-white/10 rounded text-[#40e0d0] focus:ring-[#40e0d0]"
            />
            <label class="text-sm font-medium text-gray-300">
              Verified
            </label>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Subscription Status
            </label>
            <.input
              field={@form[:subscription_status]}
              type="select"
              prompt="Send verification email"
              options={[{"Subscribed", "subscribed"}, {"Unsubscribed", "unsubscribed"}]}
              class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
            />
            <p class="mt-2 text-xs text-gray-400">
              Leave as "Send verification email" to send a verification email to the subscriber
            </p>
          </div>
        </div>
        
    <!-- Footer with Save button -->
        <div class="p-6 border-t border-white/10">
          <button
            type="submit"
            phx-disable-with="Saving..."
            class="w-full px-6 py-3 bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] text-gray-900 rounded-md hover:opacity-90 font-medium transition-all"
          >
            Save Subscriber
          </button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{subscriber: subscriber} = assigns, socket) do
    changeset = Newsletter.change_subscriber(subscriber)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"subscriber" => subscriber_params}, socket) do
    changeset =
      socket.assigns.subscriber
      |> Newsletter.change_subscriber(subscriber_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subscriber" => subscriber_params}, socket) do
    save_subscriber(socket, socket.assigns.action, subscriber_params)
  end

  defp save_subscriber(socket, :edit, subscriber_params) do
    case Newsletter.update_subscriber(socket.assigns.subscriber, subscriber_params) do
      {:ok, subscriber} ->
        notify_parent({:saved, subscriber})

        {:noreply,
         socket
         |> put_flash(:info, "Subscriber updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subscriber(socket, :new, subscriber_params) do
    # If subscription_status is empty or nil, don't set it (defaults to "subscribed")
    # and send verification email
    should_send_verification =
      is_nil(subscriber_params["subscription_status"]) or
        subscriber_params["subscription_status"] == ""

    # Clean up params - remove empty subscription_status
    cleaned_params =
      if should_send_verification do
        Map.delete(subscriber_params, "subscription_status")
      else
        subscriber_params
      end

    case Newsletter.create_subscriber(cleaned_params) do
      {:ok, subscriber} ->
        # Send verification email if subscription_status wasn't explicitly set
        if should_send_verification do
          case Newsletter.generate_verification_token(subscriber) do
            {:ok, subscriber, token} ->
              Email.send_verification_email(subscriber, token)
              notify_parent({:saved, subscriber})

              {:noreply,
               socket
               |> put_flash(:info, "Subscriber created and verification email sent")
               |> push_patch(to: socket.assigns.patch)}

            {:error, _reason} ->
              notify_parent({:saved, subscriber})

              {:noreply,
               socket
               |> put_flash(:warning, "Subscriber created but failed to send verification email")
               |> push_patch(to: socket.assigns.patch)}
          end
        else
          notify_parent({:saved, subscriber})

          {:noreply,
           socket
           |> put_flash(:info, "Subscriber created successfully")
           |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
