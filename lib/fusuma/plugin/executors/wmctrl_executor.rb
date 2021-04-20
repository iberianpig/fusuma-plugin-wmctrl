# frozen_string_literal: true

require 'singleton'

module Fusuma
  module Plugin
    module Executors
      # Control Window or Workspaces by executing wctrl
      class WmctrlExecutor < Executor
        # executor properties on config.yml
        # @return [Array<Symbol>]
        def execute_keys
          %i[workspace window]
        end

        def config_param_types
          {
            'wrap-navigation': [TrueClass, FalseClass]
          }
        end

        def initialize
          super()
          Workspace.configure(wrap_navigation: config_params(:'wrap-navigation'))
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
          event.tag.end_with?('_detector') &&
            event.record.type == :index &&
            search_command(event)
        end

        # @param event [Event]
        # @return [String]
        # @return [NilClass]
        def search_command(event)
          search_workspace_command(event) || search_window_command(event)
        end

        private

        # @param event [Event]
        # @return [String]
        # @return [NilClass]
        def search_workspace_command(event)
          index = Config::Index.new([*event.record.index.keys, :workspace])

          direction = Config.search(index)
          return unless direction.is_a?(String)

          Workspace.move_command(direction: direction)
        end

        # @param event [Event]
        # @return [String]
        # @return [NilClass]
        def search_window_command(event)
          index = Config::Index.new([*event.record.index.keys, :window])

          case property = Config.search(index)
          when 'prev', 'next'
            Window.move_command(direction: property)
          when 'fullscreen'
            Window.fullscreen(method: 'toggle')
          when 'maximized'
            Window.maximized(method: 'toggle')
          when 'close'
            Window.close
          when Hash
            if property[:fullscreen]
              Window.fullscreen(method: property[:fullscreen])
            elsif property[:maximized]
              Window.maximized(method: property[:maximized])
            end
          end
        end

        # Manage workspace
        class Workspace
          include Singleton

          attr_accessor :wrap_navigation

          class << self
            # configure properties of the workspace switcher
            # @return [NilClass]
            def configure(wrap_navigation:)
              instance.wrap_navigation = wrap_navigation
            end

            # get next workspace number
            # @return [Integer]
            def next_workspace_num(step:)
              current_workspace_num, total_workspace_num = workspace_values

              next_workspace_num = current_workspace_num + step

              return next_workspace_num unless instance.wrap_navigation

              if next_workspace_num.negative?
                next_workspace_num = total_workspace_num - 1
              elsif next_workspace_num >= total_workspace_num
                next_workspace_num = 0
              else
                next_workspace_num
              end
            end

            def move_command(direction:)
              workspace_num = case direction
                              when 'next'
                                next_workspace_num(step: 1)
                              when 'prev'
                                next_workspace_num(step: -1)
                              else
                                raise "#{direction} is invalid key"
                              end
              "wmctrl -s #{workspace_num}"
            end

            private

            # get current workspace and total workspace numbers
            # @return [Integer, Integer]
            def workspace_values
              wmctrl_output = `wmctrl -d`.split("\n")

              current_line = wmctrl_output.grep(/\*/).first
              # NOTE: stderror when failed to get desktop
              # `Cannot get current desktop properties. (_NET_CURRENT_DESKTOP or _WIN_WORKSPACE property)`
              return [0, 1] if current_line.nil?

              current_workspace_num = current_line.chars.first.to_i
              total_workspace_num = wmctrl_output.length

              [current_workspace_num, total_workspace_num]
            end
          end
        end

        # Manage Window
        class Window
          class << self
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

            def move_command(direction:)
              workspace_num = case direction
                              when 'next'
                                Workspace.next_workspace_num(step: 1)
                              when 'prev'
                                Workspace.next_workspace_num(step: -1)
                              else
                                raise "#{direction} is invalid key"
                              end
              "wmctrl -r :ACTIVE: -t #{workspace_num} ; wmctrl -s #{workspace_num}"
            end
          end
        end
      end
    end
  end
end
