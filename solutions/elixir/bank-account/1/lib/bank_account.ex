defmodule BankAccount do
  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  use GenServer

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  # Client API

  @doc """
  Open the bank account, making it available for further operations.
  """
  @spec open() :: account
  def open do
    {:ok, pid} = GenServer.start_link(__MODULE__, 0)
    pid
  end

  @doc """
  Close the bank account, making it unavailable for further operations.
  """
  @spec close(account) :: :ok
  def close(account) do
    GenServer.stop(account)
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer | {:error, :account_closed}
  def balance(account) do
    if Process.alive?(account) do
      GenServer.call(account, :balance)
    else
      {:error, :account_closed}
    end
  end

  @doc """
  Add the given amount to the account's balance.
  """
  @spec deposit(account, integer) :: :ok | {:error, :account_closed | :amount_must_be_positive}
  def deposit(account, amount) when amount > 0 do
    if Process.alive?(account) do
      GenServer.call(account, {:deposit, amount})
    else
      {:error, :account_closed}
    end
  end

  def deposit(_, _), do: {:error, :amount_must_be_positive}

  @doc """
  Subtract the given amount from the account's balance.
  """
  @spec withdraw(account, integer) ::
          :ok | {:error, :account_closed | :amount_must_be_positive | :not_enough_balance}
  def withdraw(account, amount) when amount > 0 do
    if Process.alive?(account) do
      GenServer.call(account, {:withdraw, amount})
    else
      {:error, :account_closed}
    end
  end

  def withdraw(_, _), do: {:error, :amount_must_be_positive}

  # Server callbacks

  @impl true
  def init(balance) do
    {:ok, balance}
  end

  @impl true
  def handle_call(:balance, _from, balance) do
    {:reply, balance, balance}
  end

  @impl true
  def handle_call({:deposit, amount}, _from, balance) when amount > 0 do
    new_balance = balance + amount
    {:reply, :ok, new_balance}
  end

  def handle_call({:deposit, _}, _from, balance) do
    {:reply, {:error, :amount_must_be_positive}, balance}
  end

  @impl true
  def handle_call({:withdraw, amount}, _from, balance) when amount > 0 and balance >= amount do
    new_balance = balance - amount
    {:reply, :ok, new_balance}
  end

  def handle_call({:withdraw, amount}, _from, balance) when amount > 0 do
    {:reply, {:error, :not_enough_balance}, balance}
  end

  def handle_call({:withdraw, _}, _from, balance) do
    {:reply, {:error, :amount_must_be_positive}, balance}
  end

  @impl true
  def terminate(_reason, _balance) do
    :ok
  end
end
