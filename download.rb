require 'net/http'
require 'nokogiri'

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


def search(name,count=1)
	
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



p search "vase",2