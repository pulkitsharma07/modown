require 'spec_helper'
require 'fakefs/spec_helpers'

describe Modown::CLI do
  include FakeFS::SpecHelpers

  describe "#download_model" do

    it "should download model from 3Darchive and store it on the disk" do

      Modown::CLI.download_model("6384f7c8")
      expect(File).to exist("6384f7c8.zip")
    end

  end

end
