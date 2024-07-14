# frozen_string_literal: true

require "spec_helper"
require "./lib/fusuma/plugin/wmctrl/workspace"

module Fusuma
  module Plugin
    module Wmctrl
      RSpec.describe Workspace do
        def stub_workspace_values(current:, total:)
          allow(@workspace).to receive(:workspace_values).and_return([current, total])
        end

        before { @workspace = Workspace.new }

        describe "#move_command" do
          before { stub_workspace_values(current: 1, total: 3) }

          context "with 'direction: next'" do
            before { @direction = "next" }
            it "returns wmctrl command to move NEXT workspace" do
              expect(@workspace.move_command(direction: @direction))
                .to match(/wmctrl -s 2/)
            end
            it "calls next_workspace_num" do
              expect(@workspace).to receive(:next_workspace_num).with(step: 1)
              @workspace.move_command(direction: @direction)
            end
          end
        end

        describe "#move_command_for_matrix" do
          before do
            @workspace = Workspace.new(matrix_col_size: 3)
            stub_workspace_values(current: 0, total: 9)
          end

          context "with direction: 'right'" do
            before { @direction = "right" }

            it "returns wmctrl command to move RIGHT workspace" do
              expect(@workspace.move_command_for_matrix(direction: @direction))
                .to match(/wmctrl -s 1/)
            end
            it "calls next_workspace_num_for_matrix" do
              expect(@workspace).to receive(:next_workspace_num_for_matrix)
                .with(direction: @direction)
              @workspace.move_command_for_matrix(direction: @direction)
            end
          end
          context "with direction: 'down'" do
            before { @direction = "down" }

            it "returns wmctrl command to move workspace to DOWN" do
              expect(@workspace.move_command_for_matrix(direction: @direction))
                .to match(/wmctrl -s 3/)
            end
          end
        end

        describe "#move_window_command" do
          before { stub_workspace_values(current: 1, total: 3) }

          context "with direction: 'next'" do
            before { @direction = "next" }

            it "returns wmctrl command to move NEXT workspace" do
              wmctrl_move_window = /wmctrl -r :ACTIVE: -t 2/
              wmctrl_move_workspace = /wmctrl -s 2/
              expect(@workspace.move_window_command(direction: @direction))
                .to match(wmctrl_move_window)
              expect(@workspace.move_window_command(direction: @direction))
                .to match(wmctrl_move_workspace)
            end
          end

          context "with direction: 'prev'" do
            before { @direction = "prev" }

            it "returns wmctrl command to move NEXT workspace" do
              wmctrl_move_window = /wmctrl -r :ACTIVE: -t 0/
              wmctrl_move_workspace = /wmctrl -s 0/
              expect(@workspace.move_window_command(direction: @direction))
                .to match(wmctrl_move_window)
              expect(@workspace.move_window_command(direction: @direction))
                .to match(wmctrl_move_workspace)
            end
          end
        end

        describe "#move_window_command_for_matrix" do
          before do
            @workspace = Workspace.new(matrix_col_size: 3)
            stub_workspace_values(current: 0, total: 9)
          end

          context "with direction: 'right'" do
            before { @direction = "right" }

            it "returns wmctrl command to move NEXT workspace" do
              wmctrl_move_window = /wmctrl -r :ACTIVE: -t 1/
              wmctrl_move_workspace = /wmctrl -s 1/
              expect(@workspace.move_window_command_for_matrix(direction: @direction))
                .to match(wmctrl_move_window)
              expect(@workspace.move_window_command_for_matrix(direction: @direction))
                .to match(wmctrl_move_workspace)
            end
          end
          context "with direction: 'down'" do
            before { @direction = "down" }

            it "returns wmctrl command to move NEXT workspace" do
              wmctrl_move_window = /wmctrl -r :ACTIVE: -t 3/
              wmctrl_move_workspace = /wmctrl -s 3/
              expect(@workspace.move_window_command_for_matrix(direction: @direction))
                .to match(wmctrl_move_window)
              expect(@workspace.move_window_command_for_matrix(direction: @direction))
                .to match(wmctrl_move_workspace)
            end
          end
        end

        describe "#next_workspace_num" do
          before { stub_workspace_values(current: 1, total: 3) }
          context "with step: 1" do
            before { @step = 1 }
            it { expect(@workspace.next_workspace_num(step: @step)).to eq 1 + @step }
          end
        end

        describe "#next_workspace_num_for_matrix" do
          context "without matrix option" do
            before { @workspace = Workspace.new(matrix_col_size: nil) }

            it "raises InvalidOption" do
              expect do
                @workspace.next_workspace_num_for_matrix(direction: "prev")
              end.to raise_error(Wmctrl::Workspace::MissingMatrixOption)
            end
          end

          context "with matrix_col_size: 3" do
            # +---+---+---+
            # | 0 | 1 | 2 |
            # +---+---+---+
            # | 3 | 4 | 5 |
            # +---+---+---+
            # | 6 | 7 | 8 |
            # +---+---+---+
            before do
              @workspace = Workspace.new(matrix_col_size: 3)
              stub_workspace_values(current: 1, total: 9)
            end

            context "with invalid direction" do
              before { @direction = "foo" }
              it "raises InvalidOption" do
                expect do
                  @workspace.next_workspace_num_for_matrix(direction: @direction)
                end.to raise_error(RuntimeError, "#{@direction} is invalid key")
              end
            end

            context "with direction: right" do
              before { @direction = "right" }
              it "next workspace" do
                expect(
                  @workspace.next_workspace_num_for_matrix(direction: @direction)
                ).to eq 2
              end
              context "when current_workspace is right edge" do
                before { stub_workspace_values(current: 2, total: 9) }
                it "same workspace" do
                  expect(
                    @workspace.next_workspace_num_for_matrix(direction: @direction)
                  ).to eq 2
                end

                context "with wrap_navigation: true" do
                  before { @workspace.instance_variable_set(:@wrap_navigation, true) }
                  it "same workspace" do
                    expect(
                      @workspace.next_workspace_num_for_matrix(direction: @direction)
                    ).to eq 0
                  end
                end
              end
            end
            context "with direction: down" do
              before { @direction = "down" }
              it "next workspace" do
                expect(
                  @workspace.next_workspace_num_for_matrix(direction: @direction)
                ).to eq 4
              end
              context "when current_workspace is bottom" do
                before { stub_workspace_values(current: 7, total: 9) }
                it "same workspace" do
                  expect(
                    @workspace.next_workspace_num_for_matrix(direction: @direction)
                  ).to eq 7
                end

                context "with wrap_navigation: true" do
                  before { @workspace.instance_variable_set(:@wrap_navigation, true) }
                  it "same workspace" do
                    expect(
                      @workspace.next_workspace_num_for_matrix(direction: @direction)
                    ).to eq 1
                  end
                end
              end
            end
          end
        end

        describe "#matrix_size" do
          context "with matrix_col_size" do
            before do
              @workspace = Workspace.new(matrix_col_size: 3)
              stub_workspace_values(current: 1, total: 3)
            end
            it { expect(@workspace.matrix_size(3)).to eq [1, 3] }
          end
          context "with matrix_col_size" do
            before do
              @workspace = Workspace.new(matrix_col_size: nil)
              stub_workspace_values(current: 1, total: 3)
            end
            it { expect { @workspace.matrix_size(3) }.to raise_error Workspace::MissingMatrixOption }
          end
        end
      end
    end
  end
end
