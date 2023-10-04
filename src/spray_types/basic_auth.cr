require "http/client"


@[SprayType("basic")]
class BasicAuth < Sprayer

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
        #gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        # create a http client 

        if url.scheme == "https"
            client = HTTP::Client.new(url, tls: context)
        else
            client = HTTP::Client.new(url)
        end
        # client = HTTP::Client.new(url, tls: context)
        
        
        # and some basic header options
        header = HTTP::Headers{ # basic template for headers for post/get request 
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))], # uses a random header theres only 1 by default 
            "Accept" => "*/*",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
        } 

        client.basic_auth( username, password )

        # form = "username=#{username}&password=#{password}" # request form params here
        
        # here is the basic request
        page = client.get(url.path, headers: header) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
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