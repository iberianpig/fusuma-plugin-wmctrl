# frozen_string_literal: true

require "spec_helper"

require "fusuma/plugin/executors/executor"
require "fusuma/plugin/events/event"
require "fusuma/plugin/events/records/index_record"

require "./lib/fusuma/plugin/executors/wmctrl_executor"

module Fusuma
  module Plugin
    module Executors
      RSpec.describe WmctrlExecutor do
        before do
          @workspace = double(Wmctrl::Workspace)
          allow(Wmctrl::Workspace)
            .to receive(:new)
            .and_return(@workspace)

          index = Config::Index.new([:dummy, 1, :direction])
          record = Events::Records::IndexRecord.new(index: index)
          @event = Events::Event.new(tag: "dummy_detector", record: record)
          @executor = WmctrlExecutor.new
          allow(@executor).to receive(:search_command).and_return "dummy command"
        end

        around do |example|
          ConfigHelper.load_config_yml = <<~CONFIG
            dummy:
              1:
                direction:
                  workspace: 'prev'
          CONFIG

          example.run

          Config.custom_path = nil
        end

        describe "#execute" do
          it "detach" do
            pid = rand(20)
            allow(Process).to receive(:spawn).with(@executor.search_command(@event))
              .and_return pid

            expect(Process).to receive(:detach).with(pid)

            @executor.execute(@event)
          end
        end

        describe "#executable?" do
          context "when given valid event tagged as xxxx_detector" do
            it { expect(@executor.executable?(@event)).to be_truthy }
          end

          context "when given INVALID event tagged as invalid_tag" do
            before do
              @event.tag = "invalid_tag"
            end
            it { expect(@executor.executable?(@event)).to be_falsey }
          end
        end

        describe "#search_command" do
          before do
            allow(@executor).to receive(:search_command).and_call_original

            @current_workspace = 1
            @total_workspaces = 3
            allow(@workspace)
              .to receive(:workspace_values)
              .and_return([@current_workspace, @total_workspaces])
          end
          context "when workspace: 'prev'" do
            around do |example|
              ConfigHelper.load_config_yml = <<~CONFIG
                dummy:
                  1:
                    direction:
                      workspace: 'prev'
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it "should return wmctrl command" do
              expect(@workspace).to receive(:move_command).with(direction: "prev")
              @executor.search_command(@event)
            end
          end

          context "when window: 'prev'" do
            around do |example|
              ConfigHelper.load_config_yml = <<~CONFIG
                dummy:
                  1:
                    direction:
                      window: 'prev'
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it "should return wmctrl command" do
              expect(@workspace).to receive(:move_window_command).with(direction: "prev")
              @executor.search_command(@event)
            end
          end

          context "when window: 'fullscreen'" do
            around do |example|
              ConfigHelper.load_config_yml = <<~CONFIG
                dummy:
                  1:
                    direction:
                      window: 'fullscreen'
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it "should return wmctrl command" do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -r :ACTIVE: -b toggle,fullscreen/)
            end
          end

          context "when window: [fullscreen: something]" do
            context "when fullscreen: 'toggle'" do
              around do |example|
                ConfigHelper.load_config_yml = <<~CONFIG
                  dummy:
                    1:
                      direction:
                        window:
                          fullscreen: 'toggle'
                CONFIG

                example.run

                Config.custom_path = nil
              end

              it "should return wmctrl command" do
                expect(@executor.search_command(@event))
                  .to match(/wmctrl -r :ACTIVE: -b toggle,fullscreen/)
              end
            end

            context "when fullscreen: 'add'" do
              around do |example|
                ConfigHelper.load_config_yml = <<~CONFIG
                  dummy:
                    1:
                      direction:
                        window:
                          fullscreen: 'add'
                CONFIG

                example.run

                Config.custom_path = nil
              end

              it "should return wmctrl command" do
                expect(@executor.search_command(@event))
                  .to match(/wmctrl -r :ACTIVE: -b add,fullscreen/)
              end
            end

            context "when fullscreen: 'remove'" do
              around do |example|
                ConfigHelper.load_config_yml = <<~CONFIG
                  dummy:
                    1:
                      direction:
                        window:
                          fullscreen: 'remove'
                CONFIG

                example.run

                Config.custom_path = nil
              end

              it "should return wmctrl command" do
                expect(@executor.search_command(@event))
                  .to match(/wmctrl -r :ACTIVE: -b remove,fullscreen/)
              end
            end
          end

          context "when window: 'maximized'" do
            around do |example|
              ConfigHelper.load_config_yml = <<~CONFIG
                dummy:
                  1:
                    direction:
                      window: 'maximized'
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it "should return wmctrl command" do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -r :ACTIVE: -b toggle,maximized/)
            end
          end

          context "when window: [maximized: something]" do
            context "when maximized: 'toggle'" do
              around do |example|
                ConfigHelper.load_config_yml = <<~CONFIG
                  dummy:
                    1:
                      direction:
                        window:
                          maximized: 'toggle'
                CONFIG

                example.run

                Config.custom_path = nil
              end

              it "should return wmctrl command" do
                expect(@executor.search_command(@event))
                  .to match(/wmctrl -r :ACTIVE: -b toggle,maximized/)
              end
            end

            context "when maximized: 'add'" do
              around do |example|
                ConfigHelper.load_config_yml = <<~CONFIG
                  dummy:
                    1:
                      direction:
                        window:
                          maximized: 'add'
                CONFIG

                example.run

                Config.custom_path = nil
              end

              it "should return wmctrl command" do
                expect(@executor.search_command(@event))
                  .to match(/wmctrl -r :ACTIVE: -b add,maximized/)
              end
            end

            context "when maximized: 'remove'" do
              around do |example|
                ConfigHelper.load_config_yml = <<~CONFIG
                  dummy:
                    1:
                      direction:
                        window:
                          maximized: 'remove'
                CONFIG

                example.run

                Config.custom_path = nil
              end

              it "should return wmctrl command" do
                expect(@executor.search_command(@event))
                  .to match(/wmctrl -r :ACTIVE: -b remove,maximized/)
              end
            end
          end
          context "when window: 'close'" do
            around do |example|
              ConfigHelper.load_config_yml = <<~CONFIG
                dummy:
                  1:
                    direction:
                      window: 'close'
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it "should return wmctrl command" do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -c :ACTIVE:/)
            end
          end

          describe "wrap_navigation: true" do
            around do |example|
              ConfigHelper.load_config_yml = <<~CONFIG
                plugin:
                  executors:
                    wmctrl_executor:
                      wrap-navigation: true
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it "should wrap-navigation mode" do
              expect(Wmctrl::Workspace).to receive(:new).with(
                wrap_navigation: true,
                matrix_col_size: nil
              )
              WmctrlExecutor.new
            end
          end

          describe "matrix-col-size" do
            context "with matrix-col-size: '3', right" do
              around do |example|
                ConfigHelper.load_config_yml = <<~CONFIG
                  dummy:
                    1:
                      direction:
                        window: 'right'
                  plugin:
                    executors:
                      wmctrl_executor:
                        matrix-col-size: 3
                CONFIG

                example.run

                Config.custom_path = nil
              end

              it "should return wmctrl command with index of right(next) workspace" do
                expect(@workspace).to receive(:move_window_command_for_matrix)
                  .with(direction: "right")
                @executor.search_command(@event)
              end
            end
          end
        end
      end
    end
  end
end
