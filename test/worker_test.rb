require 'test_helper'

class WorkerTest < MiniTest::Unit::TestCase
  def test_lock
    Resque.redis.stubs(:exists).with(:lock).returns(true)
    Resque.redis.expects(:sadd).with(:locked, kind_of(Resque::Worker))

    worker = Resque::Worker.new(['*'])
    worker.stubs(:register_worker).returns(true)
    worker.stubs(:unregister_worker).returns(true)
    worker.stubs(:shutdown?).returns(false)
    worker.expects(:wait_for_shutdown).returns(true)
    worker.work(0)
  end
end