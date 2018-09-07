$LOAD_PATH<<__dir__+'/../lib'
require 'base/resource'

server = TCPServer.open( Server::Config[:port] )
Action::start

loop do
	begin
		Thread.start( server.accept ) do |session|
			request = Server::Request.new session
			respond = Server::Respond.new request
			respond.send
			session.close
		end
	rescue Interrupt
		Action::interrupt
		exit
	rescue Exception => error
		Action::unexpected error
	end
end
