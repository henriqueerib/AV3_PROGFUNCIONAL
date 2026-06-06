defmodule RotinaecoWeb.HabitLive.Index do
  use RotinaecoWeb, :live_view

  alias Rotinaeco.Habits
  alias Rotinaeco.Habits.Habit
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
    user = socket.assigns.current_scope.user

    {:ok,
     socket
     |> stream(:habits, Habits.list_habits())
     |> assign(
       user: user,
       filter_category: nil,
       form: to_form(Habits.change_habit(%Habit{}), as: :habit),
       editing_habit: nil,
       category_icons: @category_icons
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, editing_habit: nil, form: to_form(Habits.change_habit(%Habit{}), as: :habit))
  end

  defp apply_action(socket, :new, _params) do
    assign(socket, editing_habit: nil, form: to_form(Habits.change_habit(%Habit{}), as: :habit))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    habit = Habits.get_habit!(id)

    if habit.user_id == socket.assigns.user.id do
      assign(socket, editing_habit: habit, form: to_form(Habits.change_habit(habit), as: :habit))
    else
      socket
      |> put_flash(:error, "Acesso negado.")
      |> push_patch(to: ~p"/habits")
    end
  end

  @impl true
  def handle_event("filter", %{"category" => cat}, socket) do
    category = if cat == "", do: nil, else: cat
    habits = Habits.list_habits(category)

    {:noreply,
     socket
     |> stream(:habits, habits, reset: true)
     |> assign(filter_category: category)}
  end

  @impl true
  def handle_event("check_in", %{"id" => id}, socket) do
    user = socket.assigns.user
    habit = Habits.get_habit!(id)

    case CheckIns.create_check_in(user, habit) do
      {:ok, _check_in} ->
        {:noreply, put_flash(socket, :info, "Check-in realizado! +#{habit.points} pts 🌱")}

      {:error, changeset} ->
        duplicate? =
          Enum.any?(changeset.errors, fn {_field, {_msg, opts}} ->
            Keyword.get(opts, :constraint) == :unique
          end)

        if duplicate? do
          {:noreply, put_flash(socket, :info, "Você já fez check-in neste hábito hoje.")}
        else
          {:noreply, put_flash(socket, :error, "Não foi possível registrar o check-in.")}
        end
    end
  end

  @impl true
  def handle_event("validate", %{"habit" => params}, socket) do
    changeset =
      case socket.assigns.editing_habit do
        nil -> Habits.change_habit(%Habit{}, params)
        habit -> Habits.change_habit(habit, params)
      end
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: :habit))}
  end

  @impl true
  def handle_event("save", %{"habit" => params}, socket) do
    user = socket.assigns.user

    result =
      case socket.assigns.editing_habit do
        nil -> Habits.create_habit(user, params)
        habit -> Habits.update_habit(habit, user, params)
      end

    case result do
      {:ok, habit} ->
        {:noreply,
         socket
         |> stream_insert(:habits, habit)
         |> assign(
           editing_habit: nil,
           form: to_form(Habits.change_habit(%Habit{}), as: :habit)
         )
         |> put_flash(:info, "Hábito salvo com sucesso!")
         |> push_patch(to: ~p"/habits")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :habit))}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    habit = Habits.get_habit!(id)

    case Habits.delete_habit(habit, socket.assigns.user) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream_delete(:habits, habit)
         |> put_flash(:info, "Hábito excluído.")}

      {:error, :unauthorized} ->
        {:noreply, put_flash(socket, :error, "Você não pode excluir este hábito.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-800">Hábitos Sustentáveis</h1>
            <p class="text-gray-500 mt-1">Crie, gerencie e faça check-in nos seus hábitos</p>
          </div>

          <.link
            patch={~p"/habits/new"}
            class="flex items-center gap-2 px-4 py-2.5 bg-green-600 text-white rounded-xl hover:bg-green-700 text-sm font-semibold transition-colors shadow-sm"
          >
            <span>+</span> Novo hábito
          </.link>
        </div>

        <%!-- Category filter --%>
        <div class="flex gap-2 flex-wrap">
          <button
            phx-click="filter"
            phx-value-category=""
            class={[
              "px-4 py-1.5 rounded-full text-sm border font-medium transition-colors",
              if(is_nil(@filter_category),
                do: "bg-green-600 text-white border-green-600",
                else:
                  "bg-white text-gray-600 border-gray-200 hover:border-green-400 hover:text-green-700"
              )
            ]}
          >
            Todos
          </button>
          <%= for cat <- ~w(alimentação transporte energia água resíduos) do %>
            <button
              phx-click="filter"
              phx-value-category={cat}
              class={[
                "px-4 py-1.5 rounded-full text-sm border font-medium transition-colors",
                if(@filter_category == cat,
                  do: "bg-green-600 text-white border-green-600",
                  else:
                    "bg-white text-gray-600 border-gray-200 hover:border-green-400 hover:text-green-700"
                )
              ]}
            >
              {Map.get(@category_icons, cat, "")} {cat}
            </button>
          <% end %>
        </div>

        <%!-- Habit form (shown when :new or :edit) --%>
        <%= if @live_action in [:new, :edit] do %>
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <h2 class="text-lg font-semibold text-gray-800 mb-4">
              {if @editing_habit, do: "✏️ Editar hábito", else: "✨ Novo hábito"}
            </h2>

            <.form
              for={@form}
              id="habit-form"
              phx-change="validate"
              phx-submit="save"
              class="space-y-4"
            >
              <.input
                field={@form[:name]}
                type="text"
                label="Nome do hábito"
                placeholder="Ex: Usar sacola reutilizável"
              />
              <.input
                field={@form[:description]}
                type="textarea"
                label="Descrição"
                placeholder="Descreva como praticar este hábito..."
              />
              <.input
                field={@form[:category]}
                type="select"
                label="Categoria"
                options={[
                  {"Selecione uma categoria...", ""}
                  | Enum.map(
                      ~w(alimentação transporte energia água resíduos),
                      &{"#{Map.get(@category_icons, &1, "")} #{&1}", &1}
                    )
                ]}
              />
              <.input
                field={@form[:points]}
                type="number"
                label="Pontos por check-in"
                min="1"
                placeholder="Ex: 10"
              />
              <div class="flex gap-3 pt-2">
                <button
                  type="submit"
                  class="px-5 py-2.5 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 transition-colors"
                  phx-disable-with="Salvando..."
                >
                  Salvar hábito
                </button>
                <.link
                  patch={~p"/habits"}
                  class="px-5 py-2.5 bg-gray-100 text-gray-700 rounded-lg font-semibold hover:bg-gray-200 transition-colors"
                >
                  Cancelar
                </.link>
              </div>
            </.form>
          </div>
        <% end %>

        <%!-- Habits stream --%>
        <div id="habits-list" phx-update="stream" class="grid gap-4">
          <div class="hidden only:block bg-white rounded-2xl shadow-sm border border-gray-100 p-12 text-center text-gray-400">
            <div class="text-5xl mb-3">🌱</div>
            <p class="font-medium text-gray-600">Nenhum hábito encontrado.</p>
            <p class="text-sm mt-1">
              Clique em <strong>+ Novo hábito</strong> para começar.
            </p>
          </div>

          <div
            :for={{id, habit} <- @streams.habits}
            id={id}
            class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 flex items-start justify-between hover:shadow-md transition-shadow"
          >
            <div class="flex items-start gap-4 flex-1 min-w-0 mr-4">
              <div class="w-11 h-11 rounded-xl bg-green-50 flex items-center justify-center text-xl flex-shrink-0">
                {Map.get(@category_icons, habit.category, "🌿")}
              </div>
              <div>
                <h3 class="font-bold text-gray-800">{habit.name}</h3>
                <p class="text-sm text-gray-500 mt-0.5 leading-relaxed">{habit.description}</p>
                <div class="flex gap-2 mt-2">
                  <span class="text-xs bg-green-100 text-green-800 px-2.5 py-1 rounded-full font-medium">
                    {habit.category}
                  </span>
                  <span class="text-xs bg-blue-100 text-blue-800 px-2.5 py-1 rounded-full font-medium">
                    +{habit.points} pts
                  </span>
                </div>
              </div>
            </div>

            <div class="flex flex-col gap-2 items-end flex-shrink-0">
              <button
                phx-click="check_in"
                phx-value-id={habit.id}
                class="flex items-center gap-1.5 px-3 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm font-semibold transition-colors"
              >
                ✓ Check-in
              </button>
              <%= if habit.user_id == @user.id do %>
                <div class="flex gap-3">
                  <.link
                    patch={~p"/habits/#{habit.id}/edit"}
                    class="text-xs text-blue-600 hover:underline font-medium"
                  >
                    Editar
                  </.link>
                  <button
                    phx-click="delete"
                    phx-value-id={habit.id}
                    data-confirm="Tem certeza que quer excluir este hábito?"
                    class="text-xs text-red-500 hover:underline font-medium"
                  >
                    Excluir
                  </button>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
