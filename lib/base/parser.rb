module Parser

	def path
		raw_path = self.raw_path.split('?')[0]
		return URI::decode(raw_path)
	end

	def get
		raw_query = self.raw_path.split('?', 2)[1]
		return {} if raw_query == nil
		return query raw_query
	end

	def post
		return {} if self.body == nil
		return query self.body if self.head['Content-Type'] == 'application/x-www-form-urlencoded'
		return form_data if self.head['Content-Type'].split('; ')[0] == 'multipart/form-data'
		return {}
	end

	def cookies
		return {} if self.head['Cookie'] == nil
		cookies = {}
		split = self.head['Cookie'].split('; ')
		split.each do |pair|
			key, value = pair.split('=')
			cookies[key] = value
		end
		return cookies
	end

	private

	def query query
		hashed_data = {}
		query = query.gsub('+', ' ')
		split = query.split('&')
		split.each do |pair|
			key, value = pair.split('=')
			next if key == nil
			key = URI::decode(key)
			value = URI::decode(value) unless value == nil
			hashed_data[key] = value
		end
		return hashed_data
	end

	def form_data
		post = {}
		boundary = self.head['Content-Type'].split('; ')[1].split('=')[1]
		self.body.split(boundary)[1..-2].each do |contents|
			temp = {}
			name = ""
			contents.split("\r\n\r\n")[0].split("\r\n")[1..-1].each do |some_headers|
				headers = some_headers.split('; ')
				first_name, first_value = headers[0].split(": ")
				temp[ first_name ] = first_value
				headers[1..-1].each do |attrib|
					key, value = attrib.split('=', 2)
					name = value[1..-2] if key == 'name'
					next if key == 'name'
					temp[key] = value[1..-2]
				end
			end
			post[name] = temp
			post[name]['value'] = contents.split("\r\n\r\n", 2)[-1].split("\r\n--")[0]
		end
		return post
	end

	def parse raw_request
		request_str = ''
		until ( line = raw_request.gets) && (line.inspect.eql?('"\r\n"') )
			next if line == nil
			request_str << line
		end
		arrayed_request = request_str.split(/\r?\n/)
		@method, @raw_path, @http_version = arrayed_request.shift.split(' ')
		@head = {}
		{}.update( arrayed_request.inject( @head ) { |headers, line|
			split = line.split(':')
			headers[split.shift] = split.join(':').strip
			headers
		})
		if @head.has_key? 'Content-Length'
			@body = raw_request.read( @head['Content-Length'].to_i )
		end
	end

end
