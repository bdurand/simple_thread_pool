# SimpleThreadPool

Simple implementation of the thread pool to manage executing tasks in parallel. The thread pool implemented by this code is designed to allow throttled, parallel execution of tasks.

Unlike some thread pools, this code does not maintain an internal queue of tasks. Instead, it simply blocks until a thread is available. This ensures that the pool memory size doesn't become bloated with 1000's of enqueued blocks of code.

The threads created for running the tasks are short lived threads and are not reused by the pool. This ensures that no thread local variables can accidentally be reused between threads.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_thread_pool'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_thread_pool

## Usage

```ruby
# Create a pool of 10 threads to work with.
thread_pool = SimpleThreadPoolnew(10)

# Execute a block of code in a thread.
# If there are no free threads in the pool, then this will block until one is freed up.
thread_pool.execute do
  # Do some work here
end

# Execute a block of code with an identifier.
# The thread pool will not run code with the same identifier in parallel
# and will execute them in the order they are called
thread_pool.execute("foo") do
  # Do some work here
end

# Block until all threads have finished executing.
# You should always call this method after all calls to `execute` have been made
thread_pool.finish
```

### Error handling.

All error handling must be conducted inside the execute block. The main thread will not be notified of any exceptions. You can use the `synchronize` method on the thread pool if you need to work with data from the main thread.

Example of how you can track any errors in a shared array.

```ruby
errors = []

thread_pool.execute do
  begin
    # Do something
  rescue Error => e
    thread_pool.synchronize { errors << e }
    raise e
  end
end

thread_pool.finish
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bdurand/simple_thread_pool.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
