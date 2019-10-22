# frozen_string_literal: true

module Fusuma
  module Plugin
    module Executors
      # Control Window or Workspaces by executing wctrl
      class WmctrlExecutor < Executor
        # execute wmctrl command
        # @param event [Event]
        # @return [nil]
        def execute(event)
          return if search_command(event).nil?

          MultiLogger.info(wmctrl: search_command(event))
          pid = fork do
            Process.daemon(true)
            exec(search_command(event))
          end

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
          index = Config::Index.new([*event.record.index.keys, :workspace])
          direction = Config.search(index)
          return if direction.nil?

          Workspace.move_workspace_command(direction: direction)
        end

        # Manage workspace
        class Workspace
          class << self
            # get workspace number
            # @return [Integer]
            def current_workspace_num
              text = `wmctrl -d`.split("\n").grep(/\*/).first
              text.chars.first.to_i
            end

            def move_workspace_command(direction:)
              new_workspace_num = case direction
                                  when 'next'
                                    current_workspace_num + 1
                                  when 'prev'
                                    current_workspace_num - 1
                                  else
                                    warn "#{direction} is invalid key"
                                    exit 1
                                  end
              "wmctrl -s #{new_workspace_num}"
            end
          end
        end
      end
    end
  end
end
