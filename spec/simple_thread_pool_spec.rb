require "spec_helper"

describe SimpleThreadPool do
  it "should work" do
    lock = Mutex.new
    results = []
    thread_pool = SimpleThreadPool.new(10)

    200.times do |i|
      thread_pool.execute do
        sleep(rand(100) / 1000.0)
        lock.synchronize do
          results << i
        end
      end
    end

    thread_pool.finish
    expect(results).to match_array((0...200).to_a)
    expect(results).to_not eq (0...200).to_a
  end

  it "should use an identifier to execute sequentially" do
    lock = Mutex.new
    results = []
    thread_pool = SimpleThreadPool.new(10)

    200.times do |i|
      thread_pool.execute("lock") do
        sleep(rand(100) / 1000.0)
        lock.synchronize do
          results << i
        end
      end
    end

    thread_pool.finish
    expect(results).to eq (0...200).to_a
  end
end
