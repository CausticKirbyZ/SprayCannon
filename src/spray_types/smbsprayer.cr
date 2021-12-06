


#
#
#
#
#
# example idea for smb. currently writing a smb lib for auth.... will update when done until then... spraycannon only supports web traffic
#
#
#
#
#
#
#
#









require "./smblib"

class SMBsprayer < Sprayer

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
        s = SMBlib::SMB.new()
        s.login_smb2("192.168.1.2")



        #
        # end of your auth check here
        # 
        
        return [username, password, valid, lockedout, mfa]
    end
end