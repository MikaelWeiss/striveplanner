defmodule StrivePlanner.RateLimiter do
  @moduledoc """
  Centralized ETS-based rate limiting for the application.
  """

  @table_name :rate_limiter

  @doc """
  Initializes the ETS table for rate limiting.
  Called on application startup.
  """
  def init do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
  end

  @doc """
  Checks if a request should be rate limited.

  ## Parameters
    - key: Unique identifier for the rate limit (e.g., "newsletter_subscribe:192.168.1.1")
    - max_requests: Maximum number of requests allowed in the time window
    - window_ms: Time window in milliseconds

  ## Returns
    - :ok if the request is allowed
    - {:error, :rate_limited} if the rate limit is exceeded
  """
  def check_rate(key, max_requests, window_ms) do
    now = System.system_time(:millisecond)

    case :ets.lookup(@table_name, key) do
      [] ->
        # First request
        :ets.insert(@table_name, {key, 1, now})
        :ok

      [{^key, count, timestamp}] ->
        if now - timestamp > window_ms do
          # Window expired, reset
          :ets.insert(@table_name, {key, 1, now})
          :ok
        else
          if count >= max_requests do
            {:error, :rate_limited}
          else
            # Increment counter
            :ets.insert(@table_name, {key, count + 1, timestamp})
            :ok
          end
        end
    end
  end

  @doc """
  Clears expired entries from the rate limiter table.
  Should be called periodically to prevent memory bloat.
  """
  def cleanup(max_age_ms \\ 3_600_000) do
    now = System.system_time(:millisecond)
    cutoff = now - max_age_ms

    :ets.select_delete(@table_name, [
      {{:_, :_, :"$1"}, [{:<, :"$1", cutoff}], [true]}
    ])
  end
end
