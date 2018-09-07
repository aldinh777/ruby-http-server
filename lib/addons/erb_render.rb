load __dir__+'/erb_session.rb'
module ErbRender

    Config = {
        allow_render: true,
        delete_after_render: true,
        render_path: __dir__+'/../../tmp'
    }

    def self.config hashpairs
        hashpairs.each do |key, value|
            self::Config[key] = value
        end
    end

    def self.render request, path, vars = {}
        return 'ERB Render not Allowed' unless self::Config[:allow_render]
		Dir::mkdir(self::Config[:render_path])            unless Dir::exist?(self::Config[:render_path])
        Dir::mkdir(self::Config[:render_path]+'/views')   unless Dir::exist?(self::Config[:render_path]+'/views')
        variables_for_erb = ErbSession::random
        rendered_erb_file = ErbSession::random
        File::open( self::Config[:render_path]+'/views/'+variables_for_erb+'.rb', 'w+' ) do |f|
            f.puts "load '"+File::dirname(__FILE__)+"/erb_session.rb'"
            f.puts "@session = nil"
            {
                get: request.get,
                post: request.post,
                cookies: request.cookies,
                session: "@session = ErbSession.new(cookies['RBID']) if @session == nil\n\treturn @session"
			}.merge( vars ).each do |var, value|
                f.puts "def #{ var }"
                f.puts "\treturn #{ value }"
                f.puts "end"
            end
        end
        system('erb -r '+self::Config[:render_path]+'/views/'+variables_for_erb+' '+path+' > '+self::Config[:render_path]+'/views/'+rendered_erb_file)
        rendered = File::read(self::Config[:render_path]+'/views/'+rendered_erb_file)
        if self::Config[:delete_after_render] then
			File::delete self::Config[:render_path]+'/views/'+rendered_erb_file
            File::delete self::Config[:render_path]+'/views/'+variables_for_erb+'.rb'
        end
        return rendered
    end
end

Route::file ext:'.erb', func:->(req, res){
	res.put ErbRender::render(req, '.'+req.path)
}

Route::dir has:'index.erb', func:->(req, res){
    res.put ErbRender::render(req, '.'+req.path+'/index.erb')
}
