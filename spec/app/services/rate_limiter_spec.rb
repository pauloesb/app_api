require 'spec_helper'

describe RateLimiter do
  JITTER = 0.1

  def expect_wait_time(start_time, wait)
    date = Time.new
    waited = date - start_time
    error_message = 'Ratelimiter should have fired approximately ' \
      "#{wait}s from start, but instead it was fired after #{waited.round(3)}s"
    expect(date).to be >= start_time + wait, error_message
    expect(date).to be <= start_time + wait + JITTER, error_message
  end

  it 'resolves immediately when not limited' do
    rate_limiter = RateLimiter.new(1, 0.1)
    start_time = Time.new
    rate_limiter.resolve_request { 'OK' }
    expect_wait_time(start_time, 0)
  end

  it 'waits when queue is full' do
    time_window = 0.1
    rate_limiter = RateLimiter.new(1, time_window)
    start_time = Time.new
    rate_limiter.resolve_request { 'OK' }
    rate_limiter.resolve_request { 'OK' }
    expect_wait_time(start_time, time_window)
  end

  it 'tests case with overlapping waits' do
    rate_limiter = RateLimiter.new(1, 0.05)
    start_time = Time.new

    rate_limiter.resolve_request { 'OK' }
    sleep(0.1)

    rate_limiter.resolve_request { 'OK' }
    expect_wait_time(start_time, 0.1)

    rate_limiter.resolve_request { 'OK' }
    expect_wait_time(start_time, 0.15)
  end

  it 'tests efficiency' do
    rate_limiter = RateLimiter.new(2, 0.05)
    start_time = Time.new

    rate_limiter.resolve_request { expect_wait_time(start_time, 0) }
    sleep(0.005)

    rate_limiter.resolve_request { expect_wait_time(start_time, 0.005) }
    sleep(0.005)

    rate_limiter.resolve_request { expect_wait_time(start_time, 0.05) }
    sleep(0.005)

    rate_limiter.resolve_request { expect_wait_time(start_time, 0.055) }
    sleep(0.005)

    rate_limiter.resolve_request { expect_wait_time(start_time, 0.1) }
    sleep(0.005)

    rate_limiter.resolve_request { expect_wait_time(start_time, 0.105) }
  end
end
