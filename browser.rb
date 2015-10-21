require 'socket'
# require 'hpricot'
require 'json'

 # host = 'www.jornada.unam.mx'		# The web server
# port = 80						# Default HTTP port
 # path = "/ultimas"					# The file we want
host = ARGV[0]
port = 2000
path = ARGV[1]
method = ARGV[2]
# This is the HTTP request we send to fetch a file
if method == 'POST'
	puts "Register your viking!"
	print "Name:  "
	viking_name = STDIN.gets.chomp
	puts
	print "Email:  "
	viking_email = STDIN.gets.chomp 

	post_query = {:viking =>{:name=>viking_name, :email=>viking_email}}.to_json
	content_length = post_query.length

	request = "POST #{path} HTTP/1.0\r\n"+
				"User-Agent: HTTPTool/1.0\r\n"+
				"Content-Type: application/x-www-form-urlencoded\r\n"+
				"Content-Length: #{content_length.to_s}\r\n"+
				"#{post_query}"+"\r\n\r\n"

elsif method == 'GET'
	request = "GET #{path} HTTP/1.0\r\n\r\n"
end

socket = TCPSocket.open(host, port) # Connect to server

socket.print(request)				# Send request

response = socket.read	

headers, body = response.split("\r\n\r\n", 2) # Split response at first blank line into headers and body
response = response.strip
cut_in_pieces = (response.match(/Content-Length: ([0-9]+)/)[1]).to_i
headers = response[0..-cut_in_pieces-1]#body
body = response[-cut_in_pieces..-1].strip

puts ""
puts body

socket.close
