# frozen_string_literal: true

require 'spec_helper'

require 'fusuma/plugin/executors/executor'
require 'fusuma/plugin/events/event'
require 'fusuma/plugin/events/records/index_record'

require './lib/fusuma/plugin/executors/wmctrl_executor'

module Fusuma
  module Plugin
    module Executors
      RSpec.describe WmctrlExecutor do
        before do
          index = Config::Index.new([:dummy, 1, :direction])
          record = Events::Records::IndexRecord.new(index: index)
          @event = Events::Event.new(tag: 'dummy_detector', record: record)
          @executor = WmctrlExecutor.new

          @default_workspace_num = 1
          allow(WmctrlExecutor::Workspace)
            .to receive(:current_workspace_num)
            .and_return(@default_workspace_num)
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

        describe '#execute' do
          it 'fork' do
            allow(Process).to receive(:daemon).with(true)
            allow(Process).to receive(:detach).with(anything)

            expect(@executor).to receive(:fork).and_yield do |block_context|
              allow(block_context).to receive(:search_command).with(@event)
              expect(block_context).to receive(:exec).with(anything)
            end

            @executor.execute(@event)
          end
        end

        describe '#executable?' do
          context 'when given valid event tagged as xxxx_detector' do
            it { expect(@executor.executable?(@event)).to be_truthy }
          end

          context 'when given INVALID event tagged as invalid_tag' do
            before do
              @event.tag = 'invalid_tag'
            end
            it { expect(@executor.executable?(@event)).to be_falsey }
          end
        end

        describe '#search_command' do
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

            it 'should return wmctrl command' do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -s #{@default_workspace_num - 1}/)
            end
          end

          context "when workspace: 'next'" do
            around do |example|
              ConfigHelper.load_config_yml = <<~CONFIG
                dummy:
                  1:
                    direction:
                      workspace: 'next'
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it 'should return wmctrl command' do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -s #{@default_workspace_num + 1}/)
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

            it 'should return wmctrl command' do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -r :ACTIVE: -t #{@default_workspace_num - 1}/)
              expect(@executor.search_command(@event))
                .to match(/wmctrl -s #{@default_workspace_num - 1}/)
            end
          end

          context "when window: 'next'" do
            around do |example|
              ConfigHelper.load_config_yml = <<~CONFIG
                dummy:
                  1:
                    direction:
                      window: 'next'
              CONFIG

              example.run

              Config.custom_path = nil
            end

            it 'should return wmctrl command' do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -r :ACTIVE: -t #{@default_workspace_num + 1}/)
              expect(@executor.search_command(@event))
                .to match(/wmctrl -s #{@default_workspace_num + 1}/)
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

            it 'should return wmctrl command' do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -r :ACTIVE: -b toggle,fullscreen/)
            end
          end

          context 'when window: [fullscreen: something]' do
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

              it 'should return wmctrl command' do
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

              it 'should return wmctrl command' do
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

              it 'should return wmctrl command' do
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

            it 'should return wmctrl command' do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -r :ACTIVE: -b toggle,maximized/)
            end
          end

          context 'when window: [maximized: something]' do
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

              it 'should return wmctrl command' do
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

              it 'should return wmctrl command' do
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

              it 'should return wmctrl command' do
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

            it 'should return wmctrl command' do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -c :ACTIVE:/)
            end
          end
        end
      end
    end
  end
end
