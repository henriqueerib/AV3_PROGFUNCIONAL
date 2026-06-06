defmodule RotinaecoWeb.CommunityFeedLive do
  use RotinaecoWeb, :live_view

  alias Rotinaeco.CheckIns

  @category_icons %{
    "alimentação" => "🥗",
    "transporte" => "🚲",
    "energia" => "⚡",
    "água" => "💧",
    "resíduos" => "♻️"
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Rotinaeco.PubSub, CheckIns.topic())
    end

    {:ok,
     socket
     |> stream(:check_ins, CheckIns.recent_check_ins(30))
     |> assign(category_icons: @category_icons)}
  end

  @impl true
  def handle_info({:check_in_created, check_in}, socket) do
    {:noreply, stream_insert(socket, :check_ins, check_in, at: 0)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <div class="flex items-start justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-800">Feed da Comunidade</h1>
            <p class="text-gray-500 mt-1">Veja o que a comunidade está praticando agora</p>
          </div>

          <div class="flex items-center gap-2 bg-green-50 text-green-700 text-sm font-medium px-4 py-2 rounded-full border border-green-200">
            <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span> Tempo real
          </div>
        </div>

        <div id="community-feed" phx-update="stream" class="space-y-3">
          <div class="hidden only:block bg-white rounded-2xl shadow-sm border border-gray-100 p-12 text-center text-gray-400">
            <div class="text-5xl mb-3">🌍</div>
            <p class="font-medium text-gray-600">Nenhum check-in ainda.</p>
            <p class="text-sm mt-1">Seja o primeiro a registrar um hábito!</p>
          </div>

          <div
            :for={{id, ci} <- @streams.check_ins}
            id={id}
            class="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 flex items-start gap-4 hover:shadow-md transition-shadow"
          >
            <div class="w-11 h-11 rounded-xl bg-green-100 flex items-center justify-center flex-shrink-0">
              <span class="text-green-700 font-extrabold text-lg">
                {String.first(ci.user.name || "?")}
              </span>
            </div>

            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <span class="font-bold text-gray-800">{ci.user.name}</span>
                <span class="text-gray-400 text-sm">praticou</span>
                <span class="font-semibold text-gray-700">{ci.habit.name}</span>
              </div>

              <div class="flex items-center gap-2 mt-1.5 flex-wrap">
                <span class="text-sm">
                  {Map.get(@category_icons, ci.habit.category, "🌿")}
                </span>
                <span class="text-xs bg-green-100 text-green-800 px-2.5 py-0.5 rounded-full font-medium">
                  {ci.habit.category}
                </span>
                <span class="text-xs bg-blue-100 text-blue-800 px-2.5 py-0.5 rounded-full font-medium">
                  +{ci.habit.points} pts
                </span>
                <span class="text-xs text-gray-400 ml-1">
                  {format_datetime(ci.inserted_at)}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp format_datetime(%DateTime{} = dt) do
    dt_brasilia = DateTime.add(dt, -3 * 3600, :second)
    Calendar.strftime(dt_brasilia, "%d/%m/%Y às %H:%M")
  end

  defp format_datetime(%NaiveDateTime{} = ndt) do
    dt_brasilia = NaiveDateTime.add(ndt, -3 * 3600, :second)
    Calendar.strftime(dt_brasilia, "%d/%m/%Y às %H:%M")
  end

  defp format_datetime(_), do: ""
end
