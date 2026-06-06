defmodule RotinaecoWeb.UserLive.Registration do
  use RotinaecoWeb, :live_view

  alias Rotinaeco.Accounts
  alias Rotinaeco.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      {:ok, push_navigate(socket, to: ~p"/dashboard")}
    else
      changeset = Accounts.change_user_registration(%User{})
      {:ok, assign(socket, form: to_form(changeset, as: :user), trigger_submit: false)}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      Accounts.change_user_registration(%User{}, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: :user))}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    case Accounts.register_user(params) do
      {:ok, _user} ->
        {:noreply, assign(socket, trigger_submit: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :user))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-[70vh] flex items-center justify-center">
        <div class="w-full max-w-md">
          <div class="text-center mb-8">
            <div class="text-5xl mb-3">🌱</div>
            <h1 class="text-3xl font-extrabold text-gray-900">Criar conta</h1>
            <p class="text-gray-500 mt-2">
              Já tem conta?
              <.link navigate={~p"/login"} class="text-green-600 hover:underline font-semibold">
                Entrar
              </.link>
            </p>
          </div>

          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
            <.form
              for={@form}
              id="sign-up-form"
              action={~p"/users/log-in"}
              phx-change="validate"
              phx-submit="save"
              phx-trigger-action={@trigger_submit}
              class="space-y-4"
            >
              <.input field={@form[:name]} type="text" label="Nome completo" placeholder="Seu nome" />
              <.input field={@form[:email]} type="email" label="E-mail" placeholder="seu@email.com" />
              <.input
                field={@form[:password]}
                type="password"
                label="Senha"
                placeholder="Mínimo 6 caracteres"
              />
              <.input
                field={@form[:bio]}
                type="textarea"
                label="Bio (opcional)"
                placeholder="Conte um pouco sobre você e seus hábitos sustentáveis..."
              />

              <button
                type="submit"
                class="w-full mt-2 px-4 py-3 bg-green-600 text-white rounded-xl font-semibold text-base hover:bg-green-700 transition-colors shadow-sm"
                phx-disable-with="Criando conta..."
              >
                Criar conta gratuitamente
              </button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
