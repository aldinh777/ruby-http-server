class ErbSession

    attr_accessor :path

    def self.random long = 64
        random = ''
        (0...long).each { random << rand(36).to_s(36) }
        return random
    end

    def initialize rbid
		if rbid == nil or not Dir::exist?(__dir__+"/../../tmp/session/#{ rbid }") then
		    random = ErbSession::random
			puts random
		    puts "<script>document.cookie = 'RBID="+random+"; path=/;';</script>"
            Dir::mkdir(__dir__+'/../../tmp')			unless Dir::exist?(__dir__+'/../../tmp')
            Dir::mkdir(__dir__+'/../../tmp/session')	unless Dir::exist?(__dir__+'/../../tmp/session')
            Dir::mkdir(__dir__+'/../../tmp/session/'+random)
            rbid = random
        end
        self.path = __dir__+'/../../tmp/session/'+rbid
    end

    def get key
        return unless File::exist?(path+'/'+key)
        return File::read(path+'/'+key)
    end

    def put key, value
        File::open(path+'/'+key, 'w') do |f|
            f.print value
        end
    end

    def [] key
        return self.get key
    end

    def []= key, value
        self.put key, value
    end

    def destroy
        Dir::glob(path+'/*').each do |f|
            File::delete(f)
        end
        Dir::rmdir(path)
    end
end
