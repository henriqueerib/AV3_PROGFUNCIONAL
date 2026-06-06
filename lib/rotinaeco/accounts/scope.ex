defmodule Rotinaeco.Accounts.Scope do
  @moduledoc """
  Define o escopo do usuário autenticado na aplicação.

  O `Rotinaeco.Accounts.Scope` é usado para carregar as informações
  do usuário logado e passá-las para os contextos e LiveViews.
  """

  alias Rotinaeco.Accounts.User

  defstruct user: nil

  @doc """
  Cria o escopo para o usuário fornecido.
  Retorna nil se nenhum usuário for passado.
  """
  def for_user(%User{} = user) do
    %__MODULE__{user: user}
  end

  def for_user(nil), do: nil
end
