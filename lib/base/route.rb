module Route

    @@file = {
        name: {},
        ext: {},
        default: ->(req, res){
        	res.headers 'Content-Length', File::size('.'+req.path)
            res.put File::read( '.'+req.path )
        }
    }

    @@dir = {
        name: {},
        has: {
            'index.html' => ->(req, res){
                res.put File::read('.'+req.path+'/index.html')
            },
        },
        default: ->(req, res){
            res.head['status_code'] = 404
            res.put File::read( Server::Config[:not_found] )
        }
    }

    @@not_found = {
        'GET' => {},
        'POST' => {},
        default: ->(req, res){
            res.status_code = 404
            res.put File::read( Server::Config[:not_found] )
        }
    }

    def self.file hashpair
        @@file[:name][ hashpair[:name] ] = hashpair[:func]  if hashpair.has_key?(:name)
        @@file[:ext][ hashpair[:ext] ] = hashpair[:func]    if hashpair.has_key?(:ext)
        @@file[:default] = hashpair[:default]               if hashpair.has_key?(:default)
    end

    def self.dir hashpair
        @@dir[:name][ hashpair[:name] ] = hashpair[:func]   if hashpair.has_key?(:name)
        @@dir[:has][ hashpair[:has] ] = hashpair[:func]     if hashpair.has_key?(:has)
        @@dir[:default] = hashpair[:default]                if hashpair.has_key?(:default)
    end

    def self.get path, func
        @@not_found['GET'][path] = func
    end

    def self.post path, func
        @@not_found['POST'][path] = func
    end

    def self.not_found func
        @@not_found[:default] = func
    end

    def self.process_file request, respond
        path = '.'+request.path
        name = File::basename( path )
        ext = File::extname( path )
        if @@file[:name].has_key?( name ) then
            @@file[:name][name].call request, respond
        elsif @@file[:ext].has_key?( ext ) then
            @@file[:ext][ext].call request, respond
        else
            @@file[:default].call request, respond
        end
    end

    def self.process_dir request, respond
        path = '.'+request.path
        name = File::basename( path )
        not_found = true
        if @@dir[:name].has_key?( name ) then
            @@dir[:name][name].call request, respond
            not_found = false
        end
        @@dir[:has].each do |file, func|
            break unless not_found
            if File::exist?( path+'/'+file ) then
                func.call(request, respond)
                not_found = false
            end
        end
        @@dir[:default].call request, respond if not_found
    end

    def self.process_not_found request, respond
        method = request.method
        path = request.path
        unless @@not_found[method][path] == nil then
            @@not_found[method][path].call request, respond
        else
            @@not_found[:default].call request, respond
        end
    end

end
