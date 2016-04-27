require 'net/http'

model_id = 'd8608cb2'

begin
	
	file_location = Net::HTTP.get_response(URI.parse("http://www.archive3d.net/?a=download&do=get&id="+model_id))['location']
	file_contents = Net::HTTP.get_response(URI.parse(file_location))

	open(model_id+".zip", "wb") do |file|
	        file.write(file_contents.body)
	end

rescue
	puts "ERROR"
else
	puts model_id+" downloaded !"
end
