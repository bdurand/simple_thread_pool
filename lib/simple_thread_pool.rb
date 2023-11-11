# frozen_string_literal: true

require "set"

# Simple thread pool for executing blocks in parallel in a controlled manner.
# Threads are not re-used by the pool to prevent any thread local variables from
# leaking out.
class SimpleThreadPool
  # @param max_threads [Integer] The maximum number of threads to spawn.
  def initialize(max_threads)
    @max_threads = max_threads
    @lock = Mutex.new
    @threads = []
    @processing_ids = []
  end

  # Call this method to spawn a thread to run the block. If the thread pool
  # is already full, this method will block until a thread is free. The block
  # is responsible for handling any exceptions that could be raised.
  #
  # The optional id argument can be used to provide an identifier for a block.
  # If one is provided, processing will be blocked if the same id is already
  # being processed. This ensures that each unique id is executed one at a time
  # sequentially.
  #
  # @param id [String, Symbol] An optional identifier for the block.
  # @yield The block to execute in a thread.
  # @return [void]
  def execute(id = nil, &block)
    loop do
      # Check if a new thread can be added without blocking.
      until can_add_thread?(id)
        sleep(0.001)
      end

      @lock.synchronize do
        # Check again inside a synchronized block if the thread can still be added.
        if can_add_thread?(id)
          @processing_ids << id unless id.nil?
          add_thread(id, block)
          return
        end
      end
    end
  end

  # Call this method to block until all current threads have finished executing.
  #
  # @return [void]
  def finish
    active_threads = @lock.synchronize { @threads.select(&:alive?) }
    active_threads.each(&:join)
    nil
  end

  # Synchronize data access across the thread pool. This method will block
  # waiting on the same internal Mutex the thread pool uses to manage scheduling
  # threads.
  #
  # @yield The block to execute in a synchronized manner.
  # @return [Object] The return value of the block.
  def synchronize(&block)
    @lock.synchronize(&block)
  end

  private

  def can_add_thread?(id)
    @threads.size < @max_threads && (id.nil? || !@processing_ids.include?(id))
  end

  # Spawn a thread in this method to ensure that it doesn't accidentally pick up any local variables.
  def add_thread(id, block)
    main_thread = Thread.current

    @threads << Thread.new do
      block.call
      # Return nil to ensure no objects are leaked.
      nil
    ensure
      @lock.synchronize do
        @processing_ids.delete(id) unless id.nil?
        @threads.delete(Thread.current)
      end
      main_thread.wakeup if main_thread.alive?
    end

    nil
  end
end
