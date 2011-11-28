require 'test_helper'

class HerokuScalerTest < MiniTest::Unit::TestCase
  def setup
    @scaler = Resque::Plugins::HerokuScaler
    @config = Resque::Plugins::HerokuScaler::Config

    @redis = mock('Mock Redis')
    @redis.stubs(:set).with(:scale, true).returns(true)
    @redis.stubs(:del).with(:scale).returns(true)
    Resque.stubs(:redis).returns(@redis)

    @manager = mock('Mock Manager')
    Resque::Plugins::HerokuScaler::Manager.stubs(:instance).returns(@manager)
  end

  def test_no_scale_for_zero_jobs
    Resque.stubs(:info).returns({ :pending => 0, :scaling => 0 })
    @manager.expects(:workers).returns(0)
    @manager.expects(:workers=).never
    @scaler.scale()
  end

  def test_scale_up_for_pending_job
    Resque.stubs(:info).returns({ :pending => 1, :scaling => 0 })
    @manager.expects(:workers).returns(0)
    @manager.expects(:workers=).with(1)
    @scaler.scale()
  end

  def test_scale_down_timeout
    @config.scale_timeout = 1
    Resque.stubs(:info).returns({ :pending => 0, :scaling => 0 })
    @manager.expects(:workers).returns(1)
    @manager.expects(:workers=).with(0)
    @scaler.scale()
    @config.scale_timeout = 90
  end

  def test_scale_down_for_zero_jobs
    Resque.stubs(:info).returns({ :pending => 0, :scaling => 1 })
    @manager.expects(:workers).returns(1)
    @manager.expects(:workers=).with(0)
    @scaler.scale()
  end

  def test_configure
    @scaler.configure do |c|
      c.scale_manager = :local
      c.scale_interval = 30
      c.poll_interval = 10
      c.scale_timeout = 20
      c.scale_with = Proc.new { |pending| 99 }
    end

    assert_equal :local, @config.scale_manager
    assert_equal 30, @config.scale_interval
    assert_equal 10, @config.poll_interval
    assert_equal 20, @config.scale_timeout
    assert_equal 99, @config.scale_for(2)

    @config.scale_manager = :heroku
    @config.scale_interval = 60
    @config.poll_interval = 5
    @config.scale_timeout = 90
    @config.scale_with = nil
  end
end