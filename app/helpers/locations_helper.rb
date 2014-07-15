module LocationsHelper
  def yellow_background_for_max(val1, val2)
    return "background: #{val1 > val2 ? 'yellow' : ''}"
  end
end
