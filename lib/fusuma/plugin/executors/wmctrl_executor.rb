# frozen_string_literal: true

require 'fusuma/plugin/executors/executor'

module Fusuma
  module Plugin
    module Executors
      # Control Window or Workspaces by executing wctrl
      class WmctrlExecutor < Executor
        # execute wmctrl command
        # @param event [Event]
        # @return [nil]
        def execute(event)
          `#{search_command(event)}`
        end

        # check executable
        # @param event [Event]
        # @return [TrueClass, FalseClass]
        def executable?(event)
          search_command(event)
        end

        private

        # @param event [Event]
        # @return [String]
        # @return [NilClass]
        def search_command(event)
          index = Config::Index.new([*event.record.index.keys, :workspace])
          direction = Config.search(index)
          return if direction.nil?

          move_workspace_command(direction: direction)
        end

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
