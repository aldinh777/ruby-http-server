module Action

	@@action = {
		interrupt: ->{
			puts "\nServer Stops with Interrupt"
		},
		start: ->{
			puts "Server Start at http://localhost:#{ Server::Config[:port] }"
		},
		unexpected: ->(error){
			if error.instance_of?(Errno::ECONNRESET) then	puts "??? Connection Reset by Peer ???"
			elsif error.instance_of?(Errno::EPIPE) then		puts "??? Broken Pipe ???"
			else
				puts "==================== Unexpected Error ===================="
				puts error.full_message
				puts "=========================================================="
			end
		}
	}

	def self.append hashpairs
		hashpairs.each do |key, value|
			@@action[key] = value
		end
	end

	def self.interrupt
		@@action[:interrupt].call
	end

	def self.start
		@@action[:start].call
	end

	def self.unexpected error
		@@action[:unexpected].call(error)
	end

	def response request
		puts "#{ request.method } #{ request.raw_path } #{ request.http_version }"
		path = '.'+request.path
		status = get_path_type(path)
		case status
		when 'File'
			Route::process_file(request, self)
		when 'Directory'
			Route::process_dir(request, self)
		else
			Route::process_not_found(request, self)
		end
	end

	def put string
		@body<< string
	end

	def headers key, value
		@head[key] = value
	end

	def send
		@session.print "#{ @http_version } #{ @status_code }\r\n"
		@head.each do |key, value|
			@session.print "#{ key }: #{ value }\r\n"
		end
		@session.print "\r\n#{ @body }"
	end

	private

	def get_path_type path
		return 'Directory'		if File::directory?(path) and 	not Server::Config[:restrict_directory]
		return 'File'			if File::exist?(path) and 		not Server::Config[:restrict_file]
		return 'NotFound'
	end

end
