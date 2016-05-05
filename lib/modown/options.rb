require 'optparse'

module Modown
  # This class handles command line options
  class Options

    def initialize
      @options = { input: nil, count: 1, format: '*' }

      # Dont know how to do case-insensitive glob matching
      @formats_glob = {}
      @formats_glob['3ds'] = '*.3[Dd][Ss]'
      @formats_glob['max'] = '*.[Mm][Aa][Xx]'
      @formats_glob['gsm'] = '*.[Gg][Ss][Mm]'
      @formats_glob['mtl'] = '*.[Mm][Tt][Ll]'
      @formats_glob['*'] = '*'
    end

    # Parse the command line arguments
    # @param args [command_line_arguments]
    # @return [Hash]
    def parse(args)
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: download.rb [options]'

        opts.on('-i', '--input INPUT', 'The search term') do |input|
          @options[:input] = input
        end

        opts.on('-c', '--count COUNT', Integer, 'Number of different models you want') do |count|
          @options[:count] = count
        end

        opts.on('-f', '--format FORMAT',
                'The file format you want.',
                "Supported formats are [#{@formats_glob.keys.join(',')}].",
        'All files are stored if no FORMAT is provided') do |format|
          @options[:format] = @formats_glob[format]
        end

        opts.on('-h', '--help', 'Displays Help') do
          puts opts
          exit
        end
      end

      parser.parse!(args)

      raise '[ERROR] Please provide the INPUT using -i flag' if @options[:input].nil?
      raise "[ERROR] Please provide a valid format for the -f flag.
      Supported formats are [#{@formats_glob.keys.join(',')}]" if @options[:format].nil?

      @options
    end
  end
end
