module Resque

  alias_method :original_info, :info

  def info
    info_with_locked = original_info
    info_with_locked[:locked] = Worker.locked.size
    return info_with_locked
  end

  def lock
    Worker.lock
  end

  def unlock
    Worker.unlock
  end
  
  def prune
    Worker.prune
  end

end