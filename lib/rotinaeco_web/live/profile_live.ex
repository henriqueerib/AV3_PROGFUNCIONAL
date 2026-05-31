defmodule RotinaecoWeb.ProfileLive do
  use RotinaecoWeb, :live_view

  alias Rotinaeco.Accounts
  alias Rotinaeco.Accounts.User

  def mount(%{"id" => user_id}, _session, socket) do
    case Accounts.get_user(String.to_integer(user_id)) do
      nil ->
        {:ok, redirect(socket, to: "/")}

      user ->
        changeset = User.profile_changeset(user, %{})

        socket =
          socket
          |> assign(user: user)
          |> assign(changeset: changeset)
          |> assign(editing: false)
          |> assign(updated: false)
          |> assign(error: nil)

        {:ok, socket}
    end
  end

  def handle_event("edit_toggle", _params, socket) do
    {:noreply, assign(socket, editing: !socket.assigns.editing, updated: false)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> User.profile_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, error: nil)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_profile(socket.assigns.user, user_params) do
      {:ok, updated_user} ->
        Phoenix.PubSub.broadcast(Rotinaeco.PubSub, "users:#{updated_user.id}", {
          :profile_updated,
          updated_user
        })

        {:noreply,
         socket
         |> assign(user: updated_user)
         |> assign(editing: false)
         |> assign(updated: true)
         |> assign(changeset: User.profile_changeset(updated_user, %{}))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset, error: "Failed to update profile")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 p-6">
      <div class="max-w-2xl mx-auto bg-white rounded-lg shadow-lg p-8">
        <div class="flex justify-between items-center mb-6">
          <h1 class="text-4xl font-bold text-gray-800">Meu Perfil</h1>
          <button
            phx-click="edit_toggle"
            class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-6 rounded-lg transition duration-200"
          >
            <%= if @editing, do: "Cancelar", else: "Editar" %>
          </button>
        </div>

        <%= if @updated do %>
          <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-6">
            Perfil atualizado com sucesso!
          </div>
        <% end %>

        <%= if @error do %>
          <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
            <%= @error %>
          </div>
        <% end %>

        <%= if @editing do %>
          <form phx-submit="save" phx-change="validate" class="space-y-6">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">Nome</label>
              <input
                type="text"
                name="user[name]"
                value={Ecto.Changeset.get_field(@changeset, :name) || ""}
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <%= if @changeset.errors[:name] do %>
                <p class="text-red-600 text-sm mt-1">
                  <%= error_to_string(@changeset.errors[:name]) %>
                </p>
              <% end %>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">Bio</label>
              <textarea
                name="user[bio]"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                rows="4"
              ><%= Ecto.Changeset.get_field(@changeset, :bio) || "" %></textarea>
            </div>

            <button
              type="submit"
              class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
            >
              Salvar Alterações
            </button>
          </form>
        <% else %>
          <div class="space-y-6">
            <div class="border-l-4 border-green-500 pl-4">
              <p class="text-gray-600 text-sm font-semibold">NOME</p>
              <p class="text-gray-900 text-lg mt-1"><%= @user.name %></p>
            </div>

            <div class="border-l-4 border-blue-500 pl-4">
              <p class="text-gray-600 text-sm font-semibold">EMAIL</p>
              <p class="text-gray-900 text-lg mt-1"><%= @user.email %></p>
            </div>

            <div class="border-l-4 border-purple-500 pl-4">
              <p class="text-gray-600 text-sm font-semibold">BIO</p>
              <p class="text-gray-900 text-lg mt-1">
                <%= if @user.bio do %>
                  <%= @user.bio %>
                <% else %>
                  <span class="text-gray-400 italic">Nenhuma bio adicionada</span>
                <% end %>
              </p>
            </div>

            <div class="border-l-4 border-yellow-500 pl-4">
              <p class="text-gray-600 text-sm font-semibold">MEMBRO DESDE</p>
              <p class="text-gray-900 text-lg mt-1">
                <%= DateTime.to_date(@user.inserted_at) |> to_string() %>
              </p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp error_to_string(error) do
    case error do
      {msg, _opts} when is_binary(msg) -> msg
      msg when is_binary(msg) -> msg
      _ -> "Erro de validação"
    end
  end
end
