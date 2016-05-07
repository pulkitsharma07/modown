require 'spec_helper'
require 'fakefs/spec_helpers'
require 'pp'

describe Modown , fakefs: true do

  include FakeFS::SpecHelpers

  describe "#download_model" do

    context "when model_id is valid" do

      it "should download model from 3Darchive and store it on the disk" do
        expect(Modown::download_model("6384f7c8")).to be(1)
        expect(File).to exist("6384f7c8.zip")
      end

    end


    context "when model_id is invalid" do

      it "should return 0" do
        expect(Modown::download_model("6384mm8")).to be(0)
      end

    end

  end


  describe "#get_model_from_zip" do

    $model_id = "6384f7c8"
    $zip_file = $model_id + '.zip'
    $location = ""
    $tmp_dir = "tmp/model_file"


    before do

      puts "Please wait , preparing the test"
      FakeFS.deactivate!

      if File.exists?(Dir.pwd + "/"+ $tmp_dir + "/6384f7c8.zip")

        $zip_file = Dir.pwd + "/" + $tmp_dir + "/" + $zip_file
        $location = Dir.pwd + "/" + $tmp_dir + "/"

      else

        $tmp_dir = ""
        FakeFS.activate!
        Modown::download_model($model_id)

      end

    end



    it "should extract everything from the file" do
      Modown::get_model_from_zip($zip_file,$tmp_dir + "/test")

      expect(File).to exist($location + "test_Labyrinth.3ds")
      expect(File).to exist($location + "test_Labyrinth.gsm")
      expect(File).to exist($location + "test_archibase.net.txt")
    end
  end


  after do
    Dir.glob(Dir.pwd + "/"+ $tmp_dir+"/*").each {|f| File.delete(f) unless f.end_with? "zip"}
  end

end
