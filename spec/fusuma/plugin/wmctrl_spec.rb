# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fusuma::Plugin::Wmctrl do
  it "has a version number" do
    expect(Fusuma::Plugin::Wmctrl::VERSION).not_to be nil
  end
end
