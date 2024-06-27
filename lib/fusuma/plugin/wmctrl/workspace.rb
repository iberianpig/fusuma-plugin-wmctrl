# frozen_string_literal: true

module Fusuma
  module Plugin
    module Wmctrl
      # Manage workspace
      class Workspace
        class MissingMatrixOption < StandardError; end

        def initialize(wrap_navigation: nil, matrix_col_size: nil)
          @wrap_navigation = wrap_navigation
          @matrix_col_size = matrix_col_size
        end

        # get next workspace number
        # @return [Integer]
        def next_workspace_num(step:)
          current_workspace_num, total_workspace_num = workspace_values

          next_workspace_num = current_workspace_num + step

          return next_workspace_num unless @wrap_navigation

          if next_workspace_num.negative?
            next_workspace_num = total_workspace_num - 1
          elsif next_workspace_num >= total_workspace_num
            next_workspace_num = 0
          else
            next_workspace_num
          end
          next_workspace_num
        end

        # @raise [MissingMatrixOption]
        # @return [Array<Integer>]
        def matrix_size(total_workspace_num)
          must_have_matrix_option!
          col_size = @matrix_col_size
          row_size = (total_workspace_num / col_size)
          [row_size.to_i, col_size.to_i]
        end

        # @raise [MissingMatrixOption]
        def must_have_matrix_option!
          return if @matrix_col_size

          # FIXME: move to executor
          warn(<<~ERRRORMESSAGE)
            Please set matrix-col-size to config.yml

            ```config.yaml
            plugin:
              executors:
                wmctrl_executor:
                  matrix-col-size: 2
            ```
          ERRRORMESSAGE
          raise MissingMatrixOption, "You need to set matrix option to config.yml"
        end

        # @return [Integer]
        # @raise [RuntimeError]
        # @raise [MissingMatrixOption]
        def next_workspace_num_for_matrix(direction:)
          must_have_matrix_option!
          current_workspace_num, total_workspace_num = workspace_values
          row_size, col_size = matrix_size(total_workspace_num)
          x = current_workspace_num % col_size
          y = current_workspace_num / col_size
          case direction
          when "right"
            if x < col_size - 1
              current_workspace_num + 1
            elsif @wrap_navigation
              current_workspace_num - (col_size - 1)
            else
              current_workspace_num
            end
          when "left"
            if x.positive?
              current_workspace_num - 1
            elsif @wrap_navigation
              current_workspace_num + (col_size - 1)
            else
              current_workspace_num
            end
          when "down"
            if y < row_size - 1
              current_workspace_num + col_size
            elsif @wrap_navigation
              (current_workspace_num + col_size) - total_workspace_num
            else
              current_workspace_num
            end
          when "up"
            if y.positive?
              current_workspace_num - col_size
            elsif @wrap_navigation
              total_workspace_num + (current_workspace_num - col_size)
            else
              current_workspace_num
            end
          else
            raise "#{direction} is invalid key"
          end
        end

        def move_command(direction:)
          workspace_num = case direction
          when "next"
            next_workspace_num(step: 1)
          when "prev"
            next_workspace_num(step: -1)
          else
            raise "#{direction} is invalid key"
          end
          "wmctrl -s #{workspace_num}"
        end

        def move_command_for_matrix(direction:)
          workspace_num = next_workspace_num_for_matrix(direction: direction)
          "wmctrl -s #{workspace_num}"
        end

        def move_window_command(direction:)
          workspace_num = case direction
          when "next"
            next_workspace_num(step: 1)
          when "prev"
            next_workspace_num(step: -1)
          else
            raise "#{direction} is invalid key"
          end
          "wmctrl -r :ACTIVE: -t #{workspace_num} ; wmctrl -s #{workspace_num}"
        end

        # @raise [MissingMatrixOption]
        def move_window_command_for_matrix(direction:)
          workspace_num = next_workspace_num_for_matrix(direction: direction)
          "wmctrl -r :ACTIVE: -t #{workspace_num} ; wmctrl -s #{workspace_num}"
        end

        private

        # get current workspace and total workspace numbers
        # @return [Integer, Integer]
        def workspace_values
          wmctrl_output = `wmctrl -d`.split("\n")

          current_line = wmctrl_output.grep(/\*/).first
          # NOTE: stderror when failed to get desktop
          # `Cannot get current desktop properties. \
          # (_NET_CURRENT_DESKTOP or _WIN_WORKSPACE property)`
          return [0, 1] if current_line.nil?

          current_workspace_num = current_line[0].to_i
          total_workspace_num = wmctrl_output.length

          [current_workspace_num, total_workspace_num]
        end
      end
    end
  end
end
