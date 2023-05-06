class Timer
  @start : Int64 = Time.utc.to_unix_ms

  # in ms
  def get_elapsed
    (Time.utc.to_unix_ms - @start).round
  end
end
