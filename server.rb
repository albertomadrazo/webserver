require 'socket'
require 'json'

def deconstruct_http_request(request)
	query_dict = {}
	action = request.match(/^[A-Z]+/).to_s
	path = request.match(/\/[a-zA-Z0-9\.]+/).to_s
	protocol = request.match(/HTTP\/1\.[0-9]/).to_s
	query = request.match(/\?[a-zA-Z0-9_=&]+/).to_s

	if query != ""
		puts "query: #{query.inspect}"
		query = query[1..-1]
		query = query.split("&")
		puts "query: #{query.inspect}"

		query.each do |x|
			x = x.split("=")
			query_dict[x[0]] = x[1]
		end

		puts "query_dict: #{query_dict.inspect}"
	end
	return [action, path, protocol,query_dict]
end

def get_requested_file file
	begin
		file = File.read(file[1..-1])
	rescue
		file = ""
	end
	file
end

def replace_in_template(vars)
	replacement_text = []
	template = File.read("thanks.html")

	vars.each do |k, v|
		v.each do |k2, v2|
			replacement_text << "<li>#{k2}: #{v2}</li>"
			#puts "#{k2}=>#{v2}"
		end
	end

	replacement_text = replacement_text.join(" ")
	template.gsub!(/<%= yield %>/, "#{replacement_text}")

	template
end
######################################### SERVER #################################

server = TCPServer.open(2000)	# Socket to listen on port 2000

puts "Server running..."

loop{                           # Servers run forever

	client = server.accept		# Wait for a client to connect

	request = []
	bit = ""
	until bit == "\r\n" do
		bit = client.gets
		request << bit
	end

	request = request.each_with_index do|x, index|
		request[index] = request[index].chomp
	end

	request.pop

	vals = deconstruct_http_request(request[0]) # refactorizar para que sea mas Rubycundo
	#puts vals
	action = vals[0]
	path = vals[1]
	protocol = vals[2]
	query = vals[3] if vals.length > 3

	#puts action, path, protocol

	if action == 'GET'
		body = get_requested_file(path)
		if body != ""
			status = "200"
			server_message = "OK"
		else
			status = "404"
			server_message = "Page Not Found"
		end
	elsif action == 'POST'
		vars = JSON.parse(request[-1])
		body = replace_in_template(vars)
		status = "200"
		server_message = "OK"
	else
		puts "UNKNOWN METHOD: #{action}"
		system(exit)
	end

	date = "Date: #{Time.new}"
	content_type = "Content-Type: text/html"
	body_length = "Content-Length: " + body.length.to_s
	response = protocol + " " + status + " " + server_message + "\n" + 
			   date + "\r\n" +
			   content_type + "\r\n" +
			   body_length + "\r\n" +#+
			   body+
			   "\r\n\r\n"

	client.print(response)
	client.close				# Disconnect from the client
}