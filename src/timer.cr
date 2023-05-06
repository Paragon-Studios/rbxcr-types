class Timer
  @start = Time.now.to_unix

  def get_elapsed
    Time.now.to_unix - @@start
  end
end
