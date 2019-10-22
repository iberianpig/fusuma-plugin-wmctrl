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
          before do
            @default_workspace_num = 1
            allow(WmctrlExecutor::Workspace)
              .to receive(:current_workspace_num)
              .and_return(@default_workspace_num)
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

            it 'should execute wmctrl command' do
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

            it 'should execute wmctrl command' do
              expect(@executor.search_command(@event))
                .to match(/wmctrl -s #{@default_workspace_num + 1}/)
            end
          end
        end
      end
    end
  end
end
