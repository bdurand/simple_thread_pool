require 'spec_helper'

describe SimpleThreadPool do

  it "should work" do
    lock = Mutex.new
    results = []
    thread_pool = SimpleThreadPool.new(10)

    1000.times do |i|
      thread_pool.execute do
        lock.synchronize { results << i }
      end
    end

    thread_pool.finish
    expect(results).to match_array((0...1000).to_a)
  end


  it "should use an identifier to execute sequentially" do
    lock = Mutex.new
    results = []
    thread_pool = SimpleThreadPool.new(10)

    1000.times do |i|
      thread_pool.execute("lock") do
        lock.synchronize { results << i }
      end
    end

    thread_pool.finish
    expect(results).to eq (0...1000).to_a
  end

end
