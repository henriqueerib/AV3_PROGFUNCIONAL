defmodule RotinaecoWeb.UserLive.Login do
  use RotinaecoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email, "password" => ""}, as: :user)

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, assign(socket, trigger_submit: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-[70vh] flex items-center justify-center">
        <div class="w-full max-w-md">
          <div class="text-center mb-8">
            <div class="text-5xl mb-3">👋</div>
            <h1 class="text-3xl font-extrabold text-gray-900">Bem-vindo de volta</h1>
            <p class="text-gray-500 mt-2">
              Não tem conta?
              <.link navigate={~p"/sign-up"} class="text-green-600 hover:underline font-semibold">
                Cadastre-se gratuitamente
              </.link>
            </p>
          </div>

          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
            <.form
              for={@form}
              id="login-form"
              action={~p"/users/log-in"}
              phx-submit="submit"
              phx-trigger-action={@trigger_submit}
              class="space-y-4"
            >
              <.input
                field={@form[:email]}
                type="email"
                label="E-mail"
                placeholder="seu@email.com"
                autocomplete="username"
                required
              />
              <.input
                field={@form[:password]}
                type="password"
                label="Senha"
                placeholder="Sua senha"
                autocomplete="current-password"
                required
              />

              <button
                type="submit"
                class="w-full mt-2 px-4 py-3 bg-green-600 text-white rounded-xl font-semibold text-base hover:bg-green-700 transition-colors shadow-sm"
                phx-disable-with="Entrando..."
              >
                Entrar
              </button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
