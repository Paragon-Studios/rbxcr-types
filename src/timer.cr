class Timer
  @start : Int64 = Time.utc.to_unix

  # in ms
  def get_elapsed
    Time.utc.to_unix - @start
  end
end
