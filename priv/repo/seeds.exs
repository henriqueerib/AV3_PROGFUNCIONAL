import Ecto.Query

alias Rotinaeco.Repo
alias Rotinaeco.Accounts
alias Rotinaeco.Habits
alias Rotinaeco.CheckIns

# Limpar dados existentes (ordem importa por causa das FKs)
Repo.delete_all(Rotinaeco.CheckIns.CheckIn)
Repo.delete_all(Rotinaeco.Habits.Habit)
Repo.delete_all(Rotinaeco.Accounts.UserToken)
Repo.delete_all(Rotinaeco.Accounts.User)

# Criar usuários
{:ok, ana} =
  Accounts.register_user(%{
    name: "Ana Silva",
    email: "ana@ecohabits.com",
    password: "senha123",
    bio: "Apaixonada por sustentabilidade e meio ambiente."
  })

{:ok, joao} =
  Accounts.register_user(%{
    name: "João Oliveira",
    email: "joao@ecohabits.com",
    password: "senha123",
    bio: "Ciclista urbano e defensor do transporte limpo."
  })

# Confirmar os usuários (para não precisar de magic link)
Repo.update_all(
  from(u in Rotinaeco.Accounts.User, where: u.id in [^ana.id, ^joao.id]),
  set: [confirmed_at: DateTime.utc_now(:second)]
)

# Criar hábitos
{:ok, habito1} =
  Habits.create_habit(ana, %{
    "name" => "Separar lixo reciclável",
    "description" => "Separar plástico, papel, vidro e metal para reciclagem.",
    "category" => "resíduos",
    "points" => 10
  })

{:ok, habito2} =
  Habits.create_habit(ana, %{
    "name" => "Ir ao trabalho de bicicleta",
    "description" => "Usar a bicicleta como transporte diário ao trabalho.",
    "category" => "transporte",
    "points" => 15
  })

{:ok, habito3} =
  Habits.create_habit(joao, %{
    "name" => "Banho de 5 minutos",
    "description" => "Limitar o tempo de banho a 5 minutos para economizar água.",
    "category" => "água",
    "points" => 8
  })

{:ok, habito4} =
  Habits.create_habit(joao, %{
    "name" => "Desligar luzes ao sair",
    "description" => "Apagar todas as luzes ao sair de um cômodo.",
    "category" => "energia",
    "points" => 5
  })

{:ok, habito5} =
  Habits.create_habit(ana, %{
    "name" => "Comer vegetariano",
    "description" => "Substituir carne por proteínas vegetais nas refeições.",
    "category" => "alimentação",
    "points" => 12
  })

# Criar check-ins de exemplo
today = Date.utc_today()
yesterday = Date.add(today, -1)
two_days_ago = Date.add(today, -2)

# Check-ins da Ana
CheckIns.create_check_in(ana, habito1)
CheckIns.create_check_in(ana, habito2)
CheckIns.create_check_in(ana, habito5)

# Check-ins do João
CheckIns.create_check_in(joao, habito3)
CheckIns.create_check_in(joao, habito4)

# Check-ins em datas anteriores (inserindo diretamente para evitar unicidade do mesmo dia)
Repo.insert!(%Rotinaeco.CheckIns.CheckIn{
  user_id: ana.id,
  habit_id: habito1.id,
  date: yesterday
})

Repo.insert!(%Rotinaeco.CheckIns.CheckIn{
  user_id: joao.id,
  habit_id: habito3.id,
  date: yesterday
})

Repo.insert!(%Rotinaeco.CheckIns.CheckIn{
  user_id: ana.id,
  habit_id: habito2.id,
  date: two_days_ago
})

IO.puts("Seeds concluídos!")
IO.puts("Usuários criados:")
IO.puts("  ana@ecohabits.com / senha123")
IO.puts("  joao@ecohabits.com / senha123")
