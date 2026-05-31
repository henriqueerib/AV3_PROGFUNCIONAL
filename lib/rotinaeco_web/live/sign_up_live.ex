defmodule RotinaecoWeb.SignUpLive do
  use RotinaecoWeb, :live_view

  alias Rotinaeco.Accounts
  alias Rotinaeco.Accounts.User

  def mount(_params, _session, socket) do
    changeset = User.registration_changeset(%User{}, %{})

    socket =
      socket
      |> assign(changeset: changeset)
      |> assign(registered: false)
      |> assign(error: nil)

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> User.registration_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, error: nil)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        Phoenix.PubSub.broadcast(Rotinaeco.PubSub, "users", {:user_registered, user})

        {:noreply,
         socket
         |> assign(registered: true)
         |> assign(changeset: User.registration_changeset(%User{}, %{}))
         |> push_navigate(to: "/profile/#{user.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset, error: "Registration failed")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center p-4">
      <div class="w-full max-w-md bg-white rounded-lg shadow-lg p-8">
        <h1 class="text-3xl font-bold text-gray-800 mb-2">Cadastro</h1>
        <p class="text-gray-600 mb-6">Crie sua conta no Rotinaeco</p>

        <%= if @registered do %>
          <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            Conta criada com sucesso!
          </div>
        <% end %>

        <%= if @error do %>
          <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            <%= @error %>
          </div>
        <% end %>

        <form phx-submit="save" phx-change="validate" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Nome</label>
            <input
              type="text"
              name="user[name]"
              value={Ecto.Changeset.get_field(@changeset, :name) || ""}
              class="mt-1 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              placeholder="Seu nome completo"
            />
            <%= if @changeset.errors[:name] do %>
              <p class="text-red-600 text-sm mt-1">
                <%= error_to_string(@changeset.errors[:name]) %>
              </p>
            <% end %>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Email</label>
            <input
              type="email"
              name="user[email]"
              value={Ecto.Changeset.get_field(@changeset, :email) || ""}
              class="mt-1 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              placeholder="seu@email.com"
            />
            <%= if @changeset.errors[:email] do %>
              <p class="text-red-600 text-sm mt-1">
                <%= error_to_string(@changeset.errors[:email]) %>
              </p>
            <% end %>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Senha</label>
            <input
              type="password"
              name="user[password]"
              class="mt-1 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              placeholder="Mínimo 6 caracteres"
            />
            <%= if @changeset.errors[:password] do %>
              <p class="text-red-600 text-sm mt-1">
                <%= error_to_string(@changeset.errors[:password]) %>
              </p>
            <% end %>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Bio (opcional)</label>
            <textarea
              name="user[bio]"
              class="mt-1 w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              placeholder="Conte um pouco sobre você"
              rows="3"
            ><%= Ecto.Changeset.get_field(@changeset, :bio) || "" %></textarea>
          </div>

          <button
            type="submit"
            class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
          >
            Cadastrar
          </button>
        </form>
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
