defmodule RotinaecoWeb.DashboardLive do
  use RotinaecoWeb, :live_view

  alias Rotinaeco.Accounts
  alias Rotinaeco.CheckIns

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    check_ins = CheckIns.list_check_ins_for_user(user.id)
    weekly_scores = CheckIns.weekly_scores(user.id, 4)
    current_week_score = CheckIns.weekly_score(user.id)
    total_score = Accounts.total_score(user.id)
    check_in_count = length(check_ins)

    {:ok,
     socket
     |> stream(:check_ins, check_ins)
     |> assign(
       weekly_score: current_week_score,
       total_score: total_score,
       weekly_scores: weekly_scores,
       check_in_count: check_in_count,
       user: user
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-8">
        <div>
          <h1 class="text-3xl font-bold text-gray-800">Meu Dashboard</h1>
          <p class="text-gray-500 mt-1">Acompanhe sua jornada sustentável</p>
        </div>

        <%!-- Score cards --%>
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
            <div class="text-3xl mb-1">🌿</div>
            <p class="text-sm text-gray-500 mb-1">Pontuação semanal</p>
            <p class="text-4xl font-bold text-green-600">{@weekly_score}</p>
            <p class="text-xs text-gray-400 mt-1">esta semana</p>
          </div>

          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
            <div class="text-3xl mb-1">🏆</div>
            <p class="text-sm text-gray-500 mb-1">Pontuação total</p>
            <p class="text-4xl font-bold text-blue-600">{@total_score}</p>
            <p class="text-xs text-gray-400 mt-1">todos os tempos</p>
          </div>

          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center">
            <div class="text-3xl mb-1">✅</div>
            <p class="text-sm text-gray-500 mb-1">Total de check-ins</p>
            <p class="text-4xl font-bold text-purple-600">{@check_in_count}</p>
            <p class="text-xs text-gray-400 mt-1">registros</p>
          </div>
        </div>

        <%!-- Weekly breakdown --%>
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Pontuação por Semana</h2>
          <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <%= for week <- @weekly_scores do %>
              <div class="flex flex-col items-center bg-gray-50 rounded-lg p-4">
                <span class="text-xs text-gray-500 mb-2">Semana de {week.week_label}</span>
                <span class="text-2xl font-bold text-green-600">{week.score}</span>
                <span class="text-xs text-gray-400 mt-1">pontos</span>
              </div>
            <% end %>
          </div>
        </div>

        <%!-- Check-ins history --%>
        <div class="bg-white rounded-xl shadow-sm border border-gray-100">
          <div class="p-5 border-b border-gray-100 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-800">Histórico de Check-ins</h2>
            <.link
              navigate={~p"/habits"}
              class="text-sm text-green-600 font-medium hover:underline"
            >
              + Novo check-in
            </.link>
          </div>

          <div id="check-ins" phx-update="stream" class="divide-y divide-gray-50">
            <div class="hidden only:block p-8 text-center text-gray-400">
              <div class="text-4xl mb-3">🌱</div>
              <p class="font-medium">Nenhum check-in ainda.</p>
              <p class="text-sm mt-1">
                Acesse
                <.link navigate={~p"/habits"} class="text-green-600 hover:underline">
                  Hábitos
                </.link>
                para começar!
              </p>
            </div>

            <div
              :for={{id, ci} <- @streams.check_ins}
              id={id}
              class="p-4 flex items-center justify-between hover:bg-gray-50 transition-colors"
            >
              <div class="flex items-center gap-3">
                <div class="w-9 h-9 rounded-full bg-green-100 flex items-center justify-center text-green-700 font-bold text-sm flex-shrink-0">
                  ✓
                </div>
                <div>
                  <p class="font-medium text-gray-800">{ci.habit.name}</p>
                  <div class="flex gap-2 mt-0.5">
                    <span class="text-xs bg-green-100 text-green-800 px-2 py-0.5 rounded-full">
                      {ci.habit.category}
                    </span>
                    <span class="text-xs bg-blue-100 text-blue-800 px-2 py-0.5 rounded-full">
                      +{ci.habit.points} pts
                    </span>
                  </div>
                </div>
              </div>

              <p class="text-sm text-gray-400 flex-shrink-0">{format_date(ci.date)}</p>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp format_date(%Date{} = date) do
    Calendar.strftime(date, "%d/%m/%Y")
  end

  defp format_date(_), do: ""
end
