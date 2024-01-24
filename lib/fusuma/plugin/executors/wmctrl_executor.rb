# frozen_string_literal: true

require_relative "../wmctrl/window"
require_relative "../wmctrl/workspace"

module Fusuma
  module Plugin
    module Executors
      # Control Window or Workspaces by executing wctrl
      class WmctrlExecutor < Executor
        class InvalidOption < StandardError; end

        # executor properties on config.yml
        # @return [Array<Symbol>]
        def execute_keys
          %i[workspace window]
        end

        def config_param_types
          {
            "wrap-navigation": [TrueClass, FalseClass],
            "matrix-col-size": [Integer]
          }
        end

        def initialize
          super()
          @workspace = Wmctrl::Workspace.new(
            wrap_navigation: config_params(:"wrap-navigation"),
            matrix_col_size: config_params(:"matrix-col-size")
          )
          @window = Wmctrl::Window.new
        end

        # execute wmctrl command
        # @param event [Event]
        # @return [nil]
        def execute(event)
          return if search_command(event).nil?

          MultiLogger.info(wmctrl: search_command(event))
          pid = Process.spawn(search_command(event))
          Process.detach(pid)
        end

        # check executable
        # @param event [Event]
        # @return [TrueClass, FalseClass]
        def executable?(event)
          event.tag.end_with?("_detector") &&
            event.record.type == :index &&
            search_command(event)
        end

        # @param event [Event]
        # @return [String]
        # @return [NilClass]
        def search_command(event)
          search_workspace_command(event) || search_window_command(event)
        rescue InvalidOption => e
          MultiLogger.error(e.message)
          exit 1
        end

        private

        # @param event [Event]
        # @return [String]
        # @return [NilClass]
        def search_workspace_command(event)
          index = Config::Index.new([*event.record.index.keys, :workspace])

          case property = Config.search(index)
          when "prev", "next"
            @workspace.move_command(direction: property)
          when "left", "right", "up", "down"
            @workspace.move_command_for_matrix(direction: property)
          when nil
            nil
          else
            raise "#{property} is invalid key"
          end
        end

        # @param event [Event]
        # @return [String]
        # @return [NilClass]
        def search_window_command(event)
          index = Config::Index.new([*event.record.index.keys, :window])

          case property = Config.search(index)
          when "prev", "next"
            @workspace.move_window_command(direction: property)
          when "left", "right", "up", "down"
            @workspace.move_window_command_for_matrix(direction: property)
          when "fullscreen"
            @window.fullscreen(method: "toggle")
          when "maximized"
            @window.maximized(method: "toggle")
          when "close"
            @window.close
          when Hash
            if property[:fullscreen]
              @window.fullscreen(method: property[:fullscreen])
            elsif property[:maximized]
              @window.maximized(method: property[:maximized])
            end
          when nil
            nil
          else
            raise "#{property} is invalid key"
          end
        end
      end
    end
  end
end
