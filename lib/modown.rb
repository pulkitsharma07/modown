require 'modown/version'
require 'modown/options'
require 'net/http'
require 'nokogiri'
require 'zip'

module Modown
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    def initialize
      @options = {}
    end

    def run(args = ARGV)
      @options = Options.new.parse(args)
      get_models(@options[:input], @options[:count], @options[:format])

    end

    # Downloads a file at a given url and writes it to disk.
    # Taken from - https://gist.github.com/Burgestrand/454926
    # @param url [URL] the url of the file to download
    # @param save_as [string] the name/path of the file to save , along with the extension
    # @return [void]
    def download(url, save_as)
      Thread.new do
        thread = Thread.current
        url = URI.parse(url)
        Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
          thread[:length] = response['Content-Length'].to_i
          puts " #{(thread[:length] / 1_000_000.0)} MB "
          open(save_as, 'wb') do |file|
            response.read_body do |fragment|
              file.write(fragment)
              thread[:done] = (thread[:done] || 0) + fragment.length
              thread[:progress] = thread[:done].quo(thread[:length]) * 100
            end
          end
        end
      end
    end

    # Downloads the model from archive3D and saves it in a zip file.
    #
    # @param model_id [String] The `id` of the model to download
    # @return [void]
    def download_model(model_id)
      print 'Please wait downloading Model'
      begin

        file_location = Net::HTTP.get_response(URI.parse('http://www.archive3d.net/?a=download&do=get&id=' + model_id))['location']
        thread = download(file_location, model_id + '.zip')
        print "#{thread[:progress].to_i}% done \r" until thread.join 1

      rescue
        puts "Can't download model",$!
      else
        puts model_id + ' downloaded !'
      end
    end

    # The zip file of the downloaded model contains different 3D formats
    # This method extracts a file with the given format from the zip file.
    # More specifically, it gets the files which matches the format (glob pattern) and extracts them
    # and saves it with the name output_file and their respective format
    #
    # @param input_zip [String] the name of the zip file
    # @param output_file [String] the desired name of the model file.
    # @param format [String] glob pattern for any of the 3D file formats ( for example <tt>".3[Dd][Ss]"</tt>)
    # @return [void]
    def get_model_from_zip(input_zip, output_file, format = '*')
      begin
        Zip::File.open(input_zip) do |zip_file|
          matches = zip_file.glob(format)
          matches.each do |entry|
            entry.extract(output_file + '.' + entry.name.split('.')[1..-1].join('.')) rescue Zip::DestinationFileExistsError
          end
        end
      rescue
        puts 'Error opening ZIP file',$!
      end
    end

    # This methods searches for 3D models on archive3D.net and returns a list of model_ids
    #
    # @param name [String] something you want to search , for example "dog", "table", etc
    # @param count [Integer] the number of models you want. The number of actual models returned are always <= count
    # @return [Array<String>] the list of the model_ids
    def search_models(name, count = 1)
      id_list = []
      begin

        page = Nokogiri::HTML(Net::HTTP.get_response(URI.parse('http://www.archive3d.net/?tag=' + name)).body)

      rescue
        puts 'There was problem contacting archive3d', $!
      else
        count.times do |x|
          x += 1
          begin
            id = page.css("#prevtable > div:nth-child(#{x}) > div > a")[0]['href'].split('id=')[1]
          rescue

          else
            id_list << id
          end
        end
      end

      puts "Found #{id_list.size} models ! \n"
      id_list
    end

    # This method integrates the {download_model} , {search_models} and {get_model_from_zip} methods
    #
    # @param name [String] the name of the thing you want to download 3D models.example "cat","bottle",etc
    # @param count [Integer] the number of models you want
    # @param format [String] the glob pattern of the desired 3D model file format
    # @return [void]
    def get_models(name, count = 1, format = '*.3[Dd][Ss]')
      search_models(name, count).each do |id|
        download_model(id)
        get_model_from_zip(id + '.zip', name + '_' + id, format)
      end
    end
  end
end
