defmodule RotinaecoWeb.Layouts do
  use RotinaecoWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <nav class="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
      <div class="max-w-5xl mx-auto px-4 py-3 flex items-center justify-between">
        <.link
          navigate={~p"/"}
          class="flex items-center gap-2 text-green-700 font-extrabold text-xl tracking-tight hover:opacity-80 transition-opacity"
        >
          🌱 EcoHabits
        </.link>
        <div class="flex items-center gap-1 text-sm">
          <%= if @current_scope && @current_scope.user do %>
            <.link
              navigate={~p"/dashboard"}
              class="px-3 py-1.5 text-gray-600 hover:text-green-700 hover:bg-green-50 rounded-lg font-medium transition-colors"
            >
              Dashboard
            </.link>
            <.link
              navigate={~p"/habits"}
              class="px-3 py-1.5 text-gray-600 hover:text-green-700 hover:bg-green-50 rounded-lg font-medium transition-colors"
            >
              Hábitos
            </.link>
            <.link
              navigate={~p"/community"}
              class="px-3 py-1.5 text-gray-600 hover:text-green-700 hover:bg-green-50 rounded-lg font-medium transition-colors"
            >
              Comunidade
            </.link>
            <.link
              navigate={~p"/profile"}
              class="px-3 py-1.5 text-gray-600 hover:text-green-700 hover:bg-green-50 rounded-lg font-medium transition-colors"
            >
              Perfil
            </.link>
            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="ml-2 px-4 py-1.5 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-colors"
            >
              Sair
            </.link>
          <% else %>
            <.link
              navigate={~p"/login"}
              class="px-3 py-1.5 text-gray-600 hover:text-green-700 hover:bg-green-50 rounded-lg font-medium transition-colors"
            >
              Entrar
            </.link>
            <.link
              navigate={~p"/sign-up"}
              class="ml-1 px-4 py-1.5 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-colors"
            >
              Cadastrar
            </.link>
          <% end %>
        </div>
      </div>
    </nav>

    <main class="max-w-5xl mx-auto px-4 py-8">
      <.flash_group flash={@flash} />
      {render_slot(@inner_block)}
    </main>
    """
  end

  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" class="mb-6">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title="Sem conexão"
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Tentando reconectar...
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Algo deu errado"
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Tentando reconectar...
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
