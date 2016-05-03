require 'spec_helper'

describe Modown, :type => :aruba do
  let(:file) { 'file.txt' }
  let(:content) { 'Hello World' }

  before(:each) { write_file file, content }

  it { expect(read(file)).to eq [content] }
end
