require 'test_helper'

class ConfigTest < MiniTest::Unit::TestCase
  def setup
    @config = Resque::Plugins::HerokuScaler::Config
  end

  def test_scale_manager_default
    assert_equal :heroku, @config.scale_manager
  end

  def test_scale_interval_default
    assert_equal 60, @config.scale_interval
  end
  
  def test_poll_interval_default
    assert_equal 5, @config.poll_interval
  end
  
  def test_scale_timeout_default
    assert_equal 90, @config.scale_timeout
  end

  def test_scale_for_default
    assert_equal 2, @config.scale_for(20)
  end

  def test_scale_with_default
    assert_equal nil, @config.scale_with
  end

  def test_custom_scale_with
    @config.scale_with = Proc.new { |pending| 99 }
    assert_equal 99, @config.scale_for(2)
    @config.scale_with = nil
  end

  def test_scale_manager
    @config.scale_manager = :local
    assert_equal :local, @config.scale_manager
    @config.scale_manager = :heroku
  end

  def test_scale_interval
    @config.scale_interval = 99
    assert_equal 99, @config.scale_interval
    @config.scale_interval = 60
  end

  def test_poll_interval
    @config.poll_interval = 99
    assert_equal 99, @config.poll_interval
    @config.poll_interval = 5
  end
  
  def test_scale_timeout
    @config.scale_timeout = 99
    assert_equal 99, @config.scale_timeout
    @config.scale_timeout = 90
  end
end