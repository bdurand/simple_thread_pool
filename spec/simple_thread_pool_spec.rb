require 'spec_helper'

describe SimpleThreadPool do

  it "should work" do
    lock = Mutex.new
    results = []
    thread_pool = SimpleThreadPool.new(10)

    100.times do |i|
      thread_pool.execute do
        lock.synchronize do
          results << i
          sleep(rand(10) / 1000.0)
        end
      end
    end

    thread_pool.finish
    expect(results).to match_array((0...100).to_a)
    expect(results).to_not eq (0...100).to_a
  end


  it "should use an identifier to execute sequentially" do
    lock = Mutex.new
    results = []
    thread_pool = SimpleThreadPool.new(10)

    100.times do |i|
      thread_pool.execute("lock") do
        lock.synchronize  do
          results << i
          sleep(rand(10) / 1000.0)
        end
      end
    end

    thread_pool.finish
    expect(results).to eq (0...100).to_a
  end

end
