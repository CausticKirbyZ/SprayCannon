require "openssl"



class IMAP < Sprayer

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

        # # some basic setups for web based auth 
        url = URI.parse @target 
        # #gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

        if url.port.nil?
            url.port = 933 if url.scheme == "imaps"
            url.port = 143 if url.scheme == "imap"
        end

        if url.scheme && url.host
            if url.scheme == "imap"
                spstatus.valid_credentials = login_imap(username, password, url.host.not_nil!, url.port.not_nil!, ssl: false )
            elsif url.scheme == "imaps"
                spstatus.valid_credentials = login_imap(username, password, url.host.not_nil!, url.port.not_nil!, ssl: true  )
            else
                raise "Invalid target scheme for imap (use imaps or imap)"
            end
        end 
        
        
        # return the SprayStatus object 
        return spstatus
    end

    CRLF = "\r\n"

    def login_imap(username : String, password : String , host : String , port : Int32, ssl : Bool = false ) : Bool 
        socket = TCPSocket.new(host, port)
        if ssl 
            tls = OpenSSL::SSL::Socket::Client.new(socket)
            socket = tls
        end 
    
        
        command = "tag LOGIN #{username} #{password}"
        socket << command
        socket << CRLF
        socket.flush
    
        resp = Array(String).new
        while(i = socket.gets)
            if i =~ /^tag OK/
                resp << i
                break
            elsif i =~ /^tag NO Authentication disabled/
                raise "Use change to tls or try not using tls"
            elsif i =~ /^tag NO Invalid credentials/
                raise "Invalid Credentials"
            elsif i =~ /^tag NO/
                raise "Command error"
            elsif i =~ /^tag BAD/
                raise "Unknown command or arguments invalid"
            else
                resp << i
            end
        end
    
        if resp.join(" ") =~ /LOGIN completed/
            return true 
        end 
        return false 
    end 

end