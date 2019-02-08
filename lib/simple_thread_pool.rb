# frozen_string_literal: true

require 'thread'
require 'set'

# Simple thread pool for executing blocks in parallel in a controlled manner.
# Threads are not re-used by the pool to prevent any thread local variables from
# leaking out.
class SimpleThreadPool

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
  def execute(id = nil, &block)
    loop do
      while @threads.size >= @max_threads || (!id.nil? && @processing_ids.include?(id))
        @processing_ids.include?(id)
        sleep(0.001)
      end
      unique_id = true
      unless id.nil?
        @lock.synchronize do
          if @processing_ids.include?(id)
            unique_id = false
          else
            @processing_ids << id
          end
        end
      end
      break if unique_id
    end

    main_thread = Thread.current

    @lock.synchronize do
      thread = Thread.new do
        begin
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
      end

      @threads << thread if thread.alive?
      thread = nil
    end
  end

  # Call this method to block until all current threads have finished executing.
  def finish
    loop do
      active_threads = @lock.synchronize { @threads.select(&:alive?) }
      break if active_threads.empty?
      active_threads.each(&:join)
    end
    nil
  end

  # Synchronize data access across the thread pool. This method will block
  # waiting on the same internal Mutex the thread pool uses to manage scheduling
  # threads.
  def synchronize(&block)
    @lock.synchronize(&block)
  end

end
