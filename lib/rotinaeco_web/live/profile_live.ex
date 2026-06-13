defmodule RotinaecoWeb.ProfileLive do
  use RotinaecoWeb, :live_view

  alias Rotinaeco.Accounts
  alias Rotinaeco.CheckIns

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    total = Accounts.total_score(user.id)
    weekly = CheckIns.weekly_score(user.id)
    form = to_form(Accounts.change_user_profile(user), as: :user)

    {:ok,
     assign(socket,
       user: user,
       form: form,
       total_score: total,
       weekly_score: weekly,
       editing: false
     )}
  end

  @impl true
  def handle_event("toggle_edit", _params, socket) do
    form = to_form(Accounts.change_user_profile(socket.assigns.user), as: :user)
    {:noreply, assign(socket, editing: !socket.assigns.editing, form: form)}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form =
      Accounts.change_user_profile(socket.assigns.user, params)
      |> Map.put(:action, :validate)
      |> to_form(as: :user)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    case Accounts.update_profile(socket.assigns.user, params) do
      {:ok, user} ->
        form = to_form(Accounts.change_user_profile(user), as: :user)

        {:noreply,
         socket
         |> assign(user: user, form: form, editing: false)
         |> put_flash(:info, "Perfil atualizado com sucesso!")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :user))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto space-y-6">
        <div>
          <h1 class="text-3xl font-bold text-gray-800">Meu Perfil</h1>
          <p class="text-gray-500 mt-1">Suas informações e estatísticas</p>
        </div>

        <%!-- Avatar + info card --%>
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <div class="flex items-start gap-5">
            <div class="w-16 h-16 rounded-2xl bg-green-100 flex items-center justify-center text-green-700 font-extrabold text-2xl flex-shrink-0">
              {String.first(@user.name || "?")}
            </div>
            <div class="flex-1 min-w-0">
              <h2 class="text-xl font-bold text-gray-800">{@user.name}</h2>
              <p class="text-gray-500 text-sm mt-0.5">{@user.email}</p>
              <p class="text-gray-600 text-sm mt-2 italic">
                {if @user.bio && @user.bio != "", do: @user.bio, else: "Nenhuma bio adicionada."}
              </p>
            </div>
            <button
              phx-click="toggle_edit"
              class={[
                "flex-shrink-0 px-4 py-2 rounded-lg text-sm font-semibold transition-colors",
                if(@editing,
                  do: "bg-gray-100 text-gray-700 hover:bg-gray-200",
                  else: "bg-green-600 text-white hover:bg-green-700"
                )
              ]}
            >
              {if @editing, do: "Cancelar", else: "Editar perfil"}
            </button>
          </div>
        </div>

        <%!-- Stats --%>
        <div class="grid grid-cols-2 gap-4">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <p class="text-sm text-gray-500 mb-1">Pontuação total</p>
            <p class="text-3xl font-extrabold text-green-600">{@total_score}</p>
            <p class="text-xs text-gray-400 mt-1">pontos acumulados</p>
          </div>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
            <p class="text-sm text-gray-500 mb-1">Esta semana</p>
            <p class="text-3xl font-extrabold text-blue-600">{@weekly_score}</p>
            <p class="text-xs text-gray-400 mt-1">pontos semanais</p>
          </div>
        </div>

        <%!-- Edit form --%>
        <%= if @editing do %>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h2 class="text-lg font-semibold text-gray-800 mb-4">Editar informações</h2>

            <.form
              for={@form}
              id="profile-form"
              phx-change="validate"
              phx-submit="save"
              class="space-y-4"
            >
              <.input field={@form[:name]} type="text" label="Nome completo" />
              <.input
                field={@form[:bio]}
                type="textarea"
                label="Bio"
                placeholder="Fale sobre você e seus hábitos sustentáveis..."
              />
              <div class="flex gap-3 pt-2">
                <button
                  type="submit"
                  class="px-5 py-2.5 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-colors"
                  phx-disable-with="Salvando..."
                >
                  Salvar alterações
                </button>
                <button
                  type="button"
                  phx-click="toggle_edit"
                  class="px-5 py-2.5 bg-gray-100 text-gray-700 rounded-lg font-semibold hover:bg-gray-200 transition-colors"
                >
                  Cancelar
                </button>
              </div>
            </.form>
          </div>
        <% end %>

        <%!-- Settings link --%>
        <div class="text-center">
          <.link
            navigate={~p"/users/settings"}
            class="text-sm text-gray-500 hover:text-green-600 hover:underline"
          >
            Configurações da conta (alterar e-mail e senha) →
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
