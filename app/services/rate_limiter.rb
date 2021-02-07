class RateLimiter
  def initialize(max_requests, time_window)
    @max_requests = max_requests
    @time_window = time_window
    @current_request =  []
  end

  # a block that makes a request is given to the method
  def resolve_request
    # TODO: Resolve as soon as possible still keeping
    # less than @max_requests in the past @time_window
     if @current_request.length >= @max_requests
      current_time = @current_request.last.to_f - @current_request.first.to_f
      sleep((current_time - @time_window)*-1)
      @current_request = []
     end
      
    @current_request << Time.now

    yield
  end
end

