require 'test_helper'

class WorkerTest < MiniTest::Unit::TestCase
  def test_wait_for_scale
    Resque.redis.stubs(:exists).with(:scale).returns(true)
    Resque.redis.expects(:set).with(regexp_matches(/^scale:(.)*$/), true)
    Resque.redis.expects(:del).with(regexp_matches(/^scale:(.)*$/))

    worker = Resque::Worker.new(['*'])    
    worker.stubs(:shutdown?).returns(true)
    worker.stubs(:register_worker).returns(true)
    worker.stubs(:unregister_worker).returns(true)
    worker.work(0)
  end

  def test_unregister_worker
    Resque.redis.expects(:del).with(regexp_matches(/^scale:(.)*$/))
    Resque.redis.stubs(:del).with(regexp_matches(/^worker:(.)*$/))
    Resque.redis.stubs(:del).with(regexp_matches(/^stat:(.)*$/))

    worker = Resque::Worker.new(['*'])    
    worker.stubs(:shutdown?).returns(true)
    worker.stubs(:register_worker).returns(true)
    worker.work(0)
  end
end