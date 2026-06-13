defmodule RotinaecoWeb.UserLive.Confirmation do
  use RotinaecoWeb, :live_view

  alias Rotinaeco.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-md mx-auto">
        <div class="bg-white rounded-lg shadow p-8 text-center">
          <div class="text-4xl mb-4">🔗</div>
          <h1 class="text-2xl font-bold text-gray-800 mb-2">Acesso via link</h1>
          <p class="text-gray-500 text-sm mb-6">{@user.email}</p>

          <.form
            :if={!@user.confirmed_at}
            for={@form}
            id="confirmation_form"
            phx-mounted={JS.focus_first()}
            phx-submit="submit"
            action={~p"/users/log-in?_action=confirmed"}
            phx-trigger-action={@trigger_submit}
            class="space-y-3"
          >
            <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
            <button
              name={@form[:remember_me].name}
              value="true"
              phx-disable-with="Entrando..."
              class="w-full px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium"
            >
              Confirmar e permanecer conectado
            </button>
            <button
              phx-disable-with="Entrando..."
              class="w-full px-4 py-2 border border-green-600 text-green-600 rounded-lg hover:bg-green-50 font-medium"
            >
              Confirmar e entrar apenas desta vez
            </button>
          </.form>

          <.form
            :if={@user.confirmed_at}
            for={@form}
            id="login_form"
            phx-submit="submit"
            phx-mounted={JS.focus_first()}
            action={~p"/users/log-in"}
            phx-trigger-action={@trigger_submit}
            class="space-y-3"
          >
            <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
            <%= if @current_scope do %>
              <button
                phx-disable-with="Entrando..."
                class="w-full px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium"
              >
                Entrar
              </button>
            <% else %>
              <button
                name={@form[:remember_me].name}
                value="true"
                phx-disable-with="Entrando..."
                class="w-full px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium"
              >
                Permanecer conectado neste dispositivo
              </button>
              <button
                phx-disable-with="Entrando..."
                class="w-full px-4 py-2 border border-green-600 text-green-600 rounded-lg hover:bg-green-50 font-medium"
              >
                Entrar apenas desta vez
              </button>
            <% end %>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    if user = Accounts.get_user_by_magic_link_token(token) do
      form = to_form(%{"token" => token}, as: "user")

      {:ok, assign(socket, user: user, form: form, trigger_submit: false),
       temporary_assigns: [form: nil]}
    else
      {:ok,
       socket
       |> put_flash(:error, "O link de acesso é inválido ou expirou.")
       |> push_navigate(to: ~p"/users/log-in")}
    end
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "user"), trigger_submit: true)}
  end
end
