module Explorer

    Config = {
        explorer: true,
        allow_upload: true
    }

    def self.config hashpairs
        hashpairs.each do |key, value|
            self::Config[key] = value
        end
    end

    def self.open request, dir
        return 'Explorer not Allowed' unless self::Config[:explorer]
        Explorer::upload(request, dir) if request.method == 'POST'
        dir = dir+'/' unless dir[-1] == '/'
        return ErbRender::render(request, __dir__+'/../../data/explorer.erb', {dir: "'"+dir+"'", post: {}})
    end

    def self.upload request, path
        return unless self::Config[:allow_upload]
        post = request.post
        return if post['file'] == nil and post['folder'] == nil
        if request.head['Content-Type'] == 'application/x-www-form-urlencoded' then Dir::mkdir( path+'/'+post['folder'] )
        elsif request.head['Content-Type'].split('; ')[0] == 'multipart/form-data' then
            return if post['file']['filename'] == ''
            File::open(path+'/'+post['file']['filename'], 'wb') { |f| f.print post['file']['value'] }
        end
    end

end

Route::dir default:->(req, res){
    res.put Explorer::open(req, '.'+req.path)
}
