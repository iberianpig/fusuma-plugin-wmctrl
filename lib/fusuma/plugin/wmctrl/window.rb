# frozen_string_literal: true

module Fusuma
  module Plugin
    module Wmctrl
      # Manage Window
      class Window
        # @param method [String] "toggle" or "add" or "remove"
        def maximized(method:)
          "wmctrl -r :ACTIVE: -b #{method},maximized_vert,maximized_horz"
        end

        def close
          "wmctrl -c :ACTIVE:"
        end

        # @param method [String] "toggle" or "add" or "remove"
        def fullscreen(method:)
          "wmctrl -r :ACTIVE: -b #{method},fullscreen"
        end
      end
    end
  end
end
