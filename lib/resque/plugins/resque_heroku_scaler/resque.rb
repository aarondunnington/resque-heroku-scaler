module Resque

  alias_method :original_info, :info
  
  def scaling
    Worker.scaling
  end

  def info
    info_with_scale = original_info
    info_with_scale[:scaling] = scaling.size
    return info_with_scale
  end
end