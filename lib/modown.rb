require 'modown/version'
require 'modown/options'
require 'net/http'
require 'nokogiri'
require 'zip'

# The main module.
module Modown
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    def initialize
      @options = {}
    end

    # This method is the entry point for the command-line app
    def run(args = ARGV)
      @options = Options.new.parse(args)

      get_models(@options[:search_term], @options[:count], @options[:format])
    end

    # This method integrates the {download_model} , {search_models} and {get_model_from_zip} methods
    #
    # @param name [String] the name of the thing you want to download 3D models.example "cat","bottle",etc
    # @param count [Integer] the number of models you want
    # @param format [String] the glob pattern of the desired 3D model file format
    # @return [void]
    def get_models(name, count = 1, format = '*.3[Dd][Ss]')
      Modown::search_models(name, count).each do |id|
        Modown::download_model(id)
        Modown::get_model_from_zip(id + '.zip', name + '_' + id, format)
      end
    end

  end
  # Downloads a file at a given url and writes it to disk.
  # Taken from - https://gist.github.com/Burgestrand/454926
  # @param url [URL] the url of the file to download
  # @param save_as [string] the name/path of the file to save, along with the extension
  # @return [void]
  def self.download(url, save_as)
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
  # @param save_to [String] Where to save the file.
  # @return [void]
  def self.download_model(model_id,save_to="")
    puts 'Please wait downloading Model'
    download_url = 'http://www.archive3d.net/?a=download&do=get&id='
    begin

      response = Net::HTTP.get_response(URI.parse(download_url + model_id))
      file_location = response['location']
      thread = download(file_location, save_to + model_id + '.zip')
      print "#{thread[:progress].to_i}% \r" until thread.join 1

    rescue
      puts "Can't download model", $!
      0
    else
      puts model_id + ' downloaded !'
      1
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
  def self.get_model_from_zip(input_zip, output_file, format = '*')
    Zip::File.open(input_zip) do |zip_file|
      matches = zip_file.glob(format)
      matches.each do |entry|
        begin

          file_complete_name = entry.name.split('.')
          file_name = file_complete_name[0]
          extension = file_complete_name[1..-1].join('.').downcase
          entry.extract(output_file + "_" + file_name + '.' + extension)
        rescue Zip::DestinationFileExistsError
        end
      end
    end
    1
  rescue
    puts 'Error opening ZIP file'
    0
  end

  # This methods searches for 3D models on archive3D.net and returns a list of model_ids
  #
  # @param name [String] something you want to search , for example "dog", "table", etc
  # @param count [Integer] the number of models you want. The number of actual models returned are always <= count
  # @return [Array<String>] the list of the model_ids
  def self.search_models(name, count = 1)
    id_list = []
    search_url = 'http://www.archive3d.net/?tag='
    begin

      page = Nokogiri::HTML(Net::HTTP.get_response(URI.parse(search_url + name)).body)

    rescue
      puts 'There was problem contacting archive3d', $!
    else
      count.times do |x|
        x += 1
        begin
          element = page.css("#prevtable > div:nth-child(#{x}) > div > a")[0]
          model_id = element['href'].split('id=')[1]
        rescue

        else
          id_list << model_id
        end
      end
    end

    puts "Found #{id_list.size} models ! \n"
    id_list
  end



end
