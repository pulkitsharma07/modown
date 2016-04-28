require 'net/http'
require 'nokogiri'
require 'zip'

def download_model(model_id)

  puts "Please wait downloading Model"

  begin

    file_location = Net::HTTP.get_response(URI.parse("http://www.archive3d.net/?a=download&do=get&id="+model_id))['location']
    file_contents = Net::HTTP.get_response(URI.parse(file_location))

    open(model_id+".zip", "wb") do |file|
      file.write(file_contents.body)
    end

  rescue
    puts "ERROR downloading"
  else
    puts model_id+" downloaded !"
  end

end

def get_3ds_from_zip(input_zip,output_file)

  Zip::File.open(input_zip) do |zip_file|
    entry = zip_file.glob('*.3[Dd][Ss]').first
    entry.extract(output_file+".3ds")
  end
end

def search_models(name,count=1)

  id_list = []

  begin

    page = Nokogiri::HTML(Net::HTTP.get_response(URI.parse("http://www.archive3d.net/?tag="+name)).body)

  rescue
    puts "There was problem contacting archive3d"
  else
    count.times do |x|
      x = x+1
      begin
        id = page.css("#prevtable > div:nth-child(#{x}) > div > a")[0]["href"].split("id=")[1]
      rescue

      else
        id_list << id
      end
    end
  end

  id_list
end


def get_models(name,count)

  search_models(name,count).each do |id|
    download_model(id)
    get_3ds_from_zip(id+".zip",name+"_"+id)
  end
end


get_models "boy",2
