module Server
	
	Config = {
		port: 5050,
		http_version: 'HTTP/1.1',
		restrict_file: false,
		restrict_directory: false,
		not_found:__dir__+'/../../data/404.html'
	}

	def self.config hashpairs
		hashpairs.each do |key, value|
			self::Config[key] = value
		end
	end

	class Request
		include Parser
		attr_reader :session, :method, :raw_path, :http_version, :head, :body

		def initialize session
			load '.http_config.rb' if File::exist?('.http_config.rb')
			@session = session
			parse session
		end
	end

	class Respond
		include Action
		attr_writer :session, :http_version, :status_code, :head, :body

		def initialize request
			self.session = request.session
			self.http_version = Server::Config[:http_version]
			self.status_code = 200
			self.head = {}
			self.body = ''
			self.response request
		end
	end

end
