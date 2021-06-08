# frozen_string_literal: true

# Manage Window
class Window
  # @param method [String] "toggle" or "add" or "remove"
  def maximized(method:)
    "wmctrl -r :ACTIVE: -b #{method},maximized_vert,maximized_horz"
  end

  def close
    'wmctrl -c :ACTIVE:'
  end

  # @param method [String] "toggle" or "add" or "remove"
  def fullscreen(method:)
    "wmctrl -r :ACTIVE: -b #{method},fullscreen"
  end
end
