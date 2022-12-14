require "sqlite3"
require "cryprompt"
require "option_parser"
require "colorize"
require "tallboy"

VERSION = "2.0.2"


if ARGV.size > 0
    # puts "Help menu:"
    puts "spdb is the interactive database behind Spraycannon".colorize(:green)
    puts "spdb does not have any cmd line flags and is entirely interactive.... (for now at least)".colorize(:red)
    puts ""
    puts "VERSION: #{VERSION}"
    exit 
end

db = DB.open "sqlite3://./spray.db"

db.exec "create table if not exists username( usernameid integer primary key autoincrement, username varchar(255) unique not null);"
db.exec "create table if not exists password( passwordid integer primary key autoincrement, password varchar(255) unique not null);"
# db.exec "create table if not exists passwords_sprayed(  usernameid integer not null , 
#                                                         passwordid integer not null ,
#                                                         date_time date,
#                                                         spraytype text, 
#                                                         primary key(usernameid, passwordid) , 
#                                                         foreign key (usernameid) references username(usernameid), 
#                                                         foreign key (passwordid) references password(passwordid) 
#                                                         );"
db.exec "create table if not exists passwords_sprayed(  usernameid integer not null , 
                                                        passwordid integer not null ,
                                                        date_time date,
                                                        spraytype text, 
                                                        foreign key (usernameid) references username(usernameid), 
                                                        foreign key (passwordid) references password(passwordid) 
                                                        );"

db.exec "create table if not exists valid_passwords(    usernameid integer not null ,
                                                        passwordid integer not null ,
                                                        date_time date,
                                                        spraytype text,
                                                        primary key(usernameid, passwordid) , 
                                                        foreign key (usernameid) references username(usernameid), 
                                                        foreign key (passwordid) references password(passwordid)                                                        
                                                        );"

db.exec "create table if not exists invalid_usernames(   
                                                            usernameid integer not null, 
                                                            date_time date, 
                                                            spraytype text, 
                                                            primary key(usernameid),
                                                            foreign key (usernameid) references username(usernameid)
                                                        );"


menu = YAML.parse "
---
exit:
  _description: Exits spdb
usernames:
  _description: Prints the usernames that have been sprayed 
passwords:
  _description: Prints out the passwords that have been sprayed
valid:
  _description: Prints out the valid credentials found
invalid:
  _description: Prints out a list of invalid usernames found
val-users:
  _description: Prints out a list of not invalid usernames
creds:
  _description: Alias for valid
sprayed:
  _description: Prints out what has been sprayed.
export:
  _description: Exports the contents to a csv file 
  usernames: 
    _description: Exports the contents to a csv file 
  passwords: 
    _description: Exports the contents to a csv file 
  valid: 
    _description: Exports the contents to a csv file 
  sprayed: 
    _description: Exports the contents to a csv file 
  invalid:
    _description: Exports the contents to a csv file 
  val-users:
    _description: Exports the list of users minus the invalid users to a csv file
clear:
  _description: Clears the screen
help: 
  _description: Prints the help screen
stats: 
  _description: Prints the stats about the database
search: 
  _description: search the database(not implemented yet)
"



# maybe implement a timeline feature ???? start is below.... idk how it would work....                                                        
# db.exec "create table if not exists timeline(   timeline_id integer not null, 
#                                                 password_id integer not null, 
#                                                 date_time date, 
#                                                 primary key(timeline_id, password_id )
#  )


# "



















t = CryPrompt::CryPrompt.new()
t.autocomplete.completion = menu
t.autocomplete.update_suggestions()
t.prompt = "[spdb]> "
t.autoprompt = true


while true 
    begin 
        ans = t.ask()
    rescue e : CryPrompt::Ctrl_C_Exception
        # puts "You pressed ctrl+c "
        ans = nil 
    end
    
    if ans
        break if ans.downcase.strip() == "exit"
        case ans.downcase.strip.split(" ").map(&.strip).join(" ")
        when "clear"
            system("clear")
        when "usernames"
            # puts "Usernames"
            # puts "---------------------------"
            # begin
            #     db.query "select * from username;" do |rs|
            #         rs.each do
            #             puts "#{rs.read(Int32)} | #{rs.read(String)}"
            #         end
            #     end
            # rescue  e
            #     puts "Error: #{e.message}"
            # end

            table = Tallboy.table do 
                header do 
                    cell "Usernames", span: 2
                end
                header ["ID","Username"]
                begin
                    db.query "select * from username;" do |rs|
                        rs.each do
                            row "#{rs.read(Int32)} | #{rs.read(String)}".split("|").map(&.strip)
                        end
                    end
                rescue  e
                    puts "Error: #{e.message}"
                end
            end
            puts table 

        when "passwords"
            # puts "Sprayed Passwords"
            # puts "---------------------------"
            # begin 
            #     db.query "select * from password;" do |rs|
            #         rs.each do
            #             puts "#{rs.read(Int32)} | #{rs.read(String)}"
            #         end
            #     end
            # rescue  e 
            #     puts "Error: #{e.message}"
            # end

            table = Tallboy.table do 
                header do 
                    cell "Passwords", span: 2
                end
                header ["ID","Password"]
                begin 
                    db.query "select * from password;" do |rs|
                        rs.each do
                            row "#{rs.read(Int32)} | #{rs.read(String)}".split("|").map(&.strip)
                        end
                    end
                rescue  e 
                    puts "Error: #{e.message}"
                end
            end
            puts table 


        when "valid", "creds"
            # puts "Valid Credentials!"
            # puts "---------------------------"
            # begin 
            #     db.query "select username.username, password.password , valid_passwords.date_time, valid_passwords.spraytype
            #     from username, password, valid_passwords
            #     where 
            #     username.usernameid = valid_passwords.usernameid
            #     and 
            #     password.passwordid = valid_passwords.passwordid;" do |rs|
            #         rs.each do
            #             puts "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String)} | #{rs.read(String)}"
            #         end
            #     end
            # rescue  e 
            #     puts "Error: #{e.message}"
            # end
            # puts ""
            # puts ""


            table = Tallboy.table do
                header ["Username", "Password","TimeStamp","SprayType" ]
                begin 
                db.query "select username.username, password.password , valid_passwords.date_time, valid_passwords.spraytype
                from username, password, valid_passwords
                where 
                username.usernameid = valid_passwords.usernameid
                and 
                password.passwordid = valid_passwords.passwordid;" do |rs|
                    rs.each do
                        row "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String)} | #{rs.read(String)}".split("|").map(&.strip())
                    end
                end
                rescue  e 
                    puts "Error: #{e.message}"
                end
                    
            end
            puts table 

        when "invalid"
            table = Tallboy.table do 
                header do 
                    cell "Invalid Usernames", span: 3
                end
                header ["Username", "Date", "SprayType" ]
                begin
                    db.query "select username.username, invalid_usernames.date_time, invalid_usernames.spraytype
                    from username, invalid_usernames
                    where 
                    username.usernameid = invalid_usernames.usernameid;" do |rs|
                        rs.each do
                            row "#{rs.read(String)} | #{rs.read(String)} | #{rs.read(String)}".split("|").map(&.strip)
                        end
                    end
                rescue  e
                    puts "Error: #{e.message}"
                end
            end
            puts table 
        when "val-users"
            puts "THIS IS NOT WORKING CORRECTLY!!!!!".colorize(:red)
            table = Tallboy.table do 
                header do 
                    cell "Not Invalid Usernames", span: 2
                end
                header ["Username","SprayType"]
                begin
                    # db.query "select username.username, passwords_sprayed.spraytype
                    # from username, passwords_sprayed, invalid_usernames
                    # where
                    # username.usernameid = passwords_sprayed.usernameid
                    # and 
                    # username.usernameid != invalid_usernames.usernameid
                    db.query "select username, spraytype 
                    from (
                        select DISTINCT username.usernameid, username.username as username, invalid_usernames.date_time as iu_date_time, passwords_sprayed.spraytype as spraytype
                        from username 
                        left join invalid_usernames on username.usernameid = invalid_usernames.usernameid
                        left join passwords_sprayed on username.usernameid = passwords_sprayed.usernameid
                        where 
                        iu_date_time is NULL
                    );
                    " do |rs|
                        rs.each do
                            # id = rs.read(Int32)
                            username = rs.read(String)
                            # date = rs.read(String|Nil)
                            spraytype = rs.read(String)
                            # row "#{rs.read(String)} | #{rs.read(String)}".split("|").map(&.strip)
                            row [username, spraytype]
                        end
                    end
                rescue  e
                    puts "Error: #{e.message}"
                end
            end
            puts table 


        
    
        when "sprayed"
            # puts "Sprayed history"
            # puts "---------------------------"
            # begin 
            #     db.query "select username.username, password.password, passwords_sprayed.date_time, passwords_sprayed.spraytype
            #     from username, password, passwords_sprayed
            #     where 
            #     username.usernameid = passwords_sprayed.usernameid
            #     and 
            #     password.passwordid = passwords_sprayed.passwordid;" do |rs|
            #         rs.each do
            #             puts "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String)} | #{rs.read(String)}"
            #         end
            #     end
            # rescue  e 
            #     puts "Error: #{e.message}"
            # end
            # puts ""
            # puts ""

            table = Tallboy.table do
                header ["Username", "Password","TimeStamp","SprayType" ]
                begin 
                    db.query "select username.username, password.password, passwords_sprayed.date_time, passwords_sprayed.spraytype
                    from username, password, passwords_sprayed
                    where 
                    username.usernameid = passwords_sprayed.usernameid
                    and 
                    password.passwordid = passwords_sprayed.passwordid;" do |rs|
                        rs.each do
                            row "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String)} | #{rs.read(String)}".split("|").map(&.strip())
                        end
                    end
                rescue  e 
                    puts "Error: #{e.message}"
                end
                
            end
            puts table 
          
    
    
    
    
    
    
    
    
    
            ######################### export features ############################
        when "export sprayed"
            puts "Exporting SPRAYED to exported_spdb_sprayed.csv ... "
            File.delete("./exported_spdb_sprayed.csv") if File.exists? "./exported_spdb_sprayed.csv"
            file = File.new("./exported_spdb_sprayed.csv", "w")
            file.puts "Username,Password,Time"
            begin 
                db.query "select username.username, password.password, passwords_sprayed.date_time, passwords_sprayed.spraytype
                from username, password, passwords_sprayed
                where 
                username.usernameid = passwords_sprayed.usernameid
                and 
                password.passwordid = passwords_sprayed.passwordid;" do |rs|
                    rs.each do
                        line = "#{rs.read(String)} , #{rs.read(String)} , #{ rs.read(String)} , #{rs.read(String)}"
                        # puts line 
                        file.puts line
                        # file.puts "#{rs.read(String)},#{rs.read(String)},#{ rs.read(String) }"
                    end
                end
            rescue  e 
                puts "Error: #{e.message}"
            end
            file.close
            puts "Data Exported"
            puts ""
            puts ""
        when "export valid"
            puts "Exporting VALID to exported_spdb_valid.csv ... "
            File.delete("./exported_spdb_valid.csv") if File.exists? "./exported_spdb_valid.csv"
            file = File.new("./exported_spdb_valid.csv", "w")
            file.puts "Username,Password,Time"
            begin 
                db.query "select username.username, invalid_usernames.date_time, invalid_usernames.spraytype
                from username, invalid_usernames
                where 
                username.usernameid = invalid_usernames.usernameid;" do |rs|
                    rs.each do
                        line = "#{rs.read(String)} , #{ rs.read(String)} , #{rs.read(String)}"
                        # puts line 
                        file.puts line
                        # file.puts "#{rs.read(String)},#{rs.read(String)},#{ rs.read(String) }"
                    end
                end
            rescue  e 
                puts "Error: #{e.message}"
            end
            file.close
            puts "Data Exported"
            puts ""
            puts ""
        when "export invalid"
            puts "Exporting INVALID to exported_spdb_invalid.csv ... "
            File.delete("./exported_spdb_invalid.csv") if File.exists? "./exported_spdb_invalid.csv"
            file = File.new("./exported_spdb_invalid.csv", "w")
            file.puts "Username,Time,SprayType"
            begin 
                db.query "select username.username, invalid_usernames.date_time, invalid_usernames.spraytype
                    from username, invalid_usernames
                    where 
                    username.usernameid = invalid_usernames.usernameid;" do |rs|
                    rs.each do
                        line = "#{rs.read(String)} , #{ rs.read(String)} , #{rs.read(String)}"
                        # puts line 
                        file.puts line
                        # file.puts "#{rs.read(String)},#{rs.read(String)},#{ rs.read(String) }"
                    end
                end
            rescue  e 
                puts "Error: #{e.message}"
            end
            file.close
            puts "Data Exported"
            puts ""
            puts ""
        when "export val-users"
            puts "Exporting usernames minus invalid usernames to exported_spdb_val-users.csv ... "
            File.delete("./exported_spdb_val-users.csv") if File.exists? "./exported_spdb_val-users.csv"
            file = File.new("./exported_spdb_val-users.csv", "w")
            file.puts "Username,SprayType"
            begin 
                db.query "select username, spraytype 
                from (
                    select DISTINCT username.usernameid, username.username as username, invalid_usernames.date_time as iu_date_time, passwords_sprayed.spraytype as spraytype
                    from username 
                    left join invalid_usernames on username.usernameid = invalid_usernames.usernameid
                    left join passwords_sprayed on username.usernameid = passwords_sprayed.usernameid
                    where 
                    iu_date_time is NULL
                );" do |rs|
                    rs.each do
                        line = "#{ rs.read(String)} , #{rs.read(String)}"
                        # puts line 
                        file.puts line
                        # file.puts "#{rs.read(String)},#{rs.read(String)},#{ rs.read(String) }"
                    end
                end
            rescue  e 
                puts "Error: #{e.message}"
            end
            file.close
            puts "Data Exported"
            puts ""
            puts ""
        when "export passwords"
            puts "Exporting VALID to exported_spdb_passwords.csv ... "
            File.delete("./exported_spdb_passwords.csv") if File.exists? "./exported_spdb_passwords.csv"
            file = File.new("./exported_spdb_passwords.csv", "w")
            file.puts "ID,Password"
            begin 
                db.query "select * from password;" do |rs|
                    rs.each do
                        line =  "#{rs.read(Int32)}, #{rs.read(String)}"
                        file.puts line
                    end
                end
            rescue  e 
                puts "Error: #{e.message}"
            end
            file.close
            puts "Data Exported"
        when "export usernames"
            puts "Exporting VALID to exported_spdb_usernames.csv ... "
            File.delete("./exported_spdb_usernames.csv") if File.exists? "./exported_spdb_usernames.csv"
            file = File.new("./exported_spdb_usernames.csv", "w")
            file.puts "ID,Username"
            begin
                db.query "select * from username;" do |rs|
                    rs.each do
                        line =  "#{rs.read(Int32)}, #{rs.read(String)}"
                        file.puts line
                    end
                end
            rescue  e
                puts "Error: #{e.message}"
            end
            file.close
            puts "Data Exported"
    
    
        when "export"
            puts "export [table]"
            puts "ex. export passwords"
            puts ""
            puts ""
        when "export help"
            puts "export [table]"
            puts "Tables: \n----------------------------------------"
            tables = ["username","password","passwords_sprayed","valid_passwords"]
            tables.each do |tab|
                puts tab 
            end
            puts ""
            puts ""



            ######################### extra/other/search features ############################

        when "stats"
            # puts "Stats:"
            # puts "----------------------------"
           
            
            table = Tallboy.table do 
                header do 
                    cell "Statistics", span: 2
                end
                dbtables = ["username","password","passwords_sprayed","valid_passwords","invalid_usernames"]
                dbtables.each do |dbtab| 
                    begin 
                        db.query "select COUNT(*) from #{dbtab};" do |rs|
                            rs.each do
                               row ["#{dbtab}", "#{rs.read(Int64)}"]
                            end
                        end
                    rescue e 
                        puts "Something broke with table: #{dbtab}"
                        puts e.message 
                    end
    
                end
            end
            puts table 


            # puts ""
            # puts ""

        when "help"
            puts "SPDB: the backend database util for spraycannon!"
            puts "VERSION: #{VERSION}"
            puts "#{" " * 2}Commands:"
            puts "#{" " * 4}usernames              : Displays all usernames that have been sprayed at least once."
            puts "#{" " * 4}passwords              : Displays all passwords that have been sprayed at least once."
            puts "#{" " * 4}sprayed                : Displays a list of sprayed usernames and password combinations."
            puts "#{" " * 4}valid,creds            : Displays a list of valid username and password combinations."
            puts "#{" " * 4}invalid                : Displays a list of invalid usernames determined by a spray."
            puts "#{" " * 4}export                 : Exports data out to a csv file. <export help>"
            puts "#{" " * 4}stats                  : Prints out statistics about the database."
            puts "#{" " * 4}help                   : prints the help menu " 
            puts "#{" " * 4}"
            puts "#{" " * 2}Extra options:"
            puts "#{" " * 4}search <search string> : search sprayed items for the specified string"
            puts "#{" " * 4}valid <search string>  : Display valid items that match the search criterea."
            puts "#{" " * 4}"
            puts "#{" " * 2}Notes:"
            puts "#{" " * 4}Search Strings are case insensitive"
            puts ""
            puts ""
    
        when "search"
            puts "search case insensitive for the supplied string."
            puts "'serach help' for more help"
        when "search help"
            puts "ex: serach o365 "
            puts "This will display all the entries that have been sprayed with the O365 spraytype"
        else # serach features here 
            # puts "In the else options"
            # valid [spraytype]
            if ans.downcase.strip.split(" ").map(&.strip).join(" ").starts_with?( "valid" ) || ans.downcase.strip.split(" ").map(&.strip).join(" ").starts_with? "creds"
                # puts "Showing valid for search: " + "#{ans.downcase.strip.split(" ").map(&.strip)[1] unless ans.downcase.strip.split(" ").map(&.strip).size < 2 }".colorize(:yellow).to_s
                # puts "--------------"

                # begin 
                #     db.query "select username.username, password.password , valid_passwords.date_time, valid_passwords.spraytype
                #     from username, password, valid_passwords
                #     where 
                #     username.usernameid = valid_passwords.usernameid
                #     and 
                #     password.passwordid = valid_passwords.passwordid;" do |rs|
                #         rs.each do
                #             line = "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String)} | #{rs.read(String)}" 
                #             puts line if line.downcase.includes? ans.downcase.strip.split(" ").map(&.strip)[1].downcase
                #         end
                #     end
                # rescue  e 
                #     puts "Error: #{e.message}"
                # end
                # puts ""
                # puts ""
                table = Tallboy.table do
                    header ["Username", "Password","TimeStamp","SprayType" ]
                    begin 
                    db.query "select username.username, password.password , valid_passwords.date_time, valid_passwords.spraytype
                    from username, password, valid_passwords
                    where 
                    username.usernameid = valid_passwords.usernameid
                    and 
                    password.passwordid = valid_passwords.passwordid;" do |rs|
                        rs.each do
                            line = "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String)} | #{rs.read(String)}" 
                            row line.split("|").map(&.strip()) if line.downcase.includes? ans.downcase.strip.split(" ").map(&.strip)[1].downcase
                        end
                    end
                    rescue  e 
                        puts "Error: #{e.message}"
                    end
                        
                end
                puts table 


            elsif ans.downcase.strip.split(" ").map(&.strip).join(" ").starts_with?( "search" ) 
                # puts "Showing valid for search: " + "#{ans.downcase.strip.split(" ").map(&.strip)[1] unless ans.downcase.strip.split(" ").map(&.strip).size < 2 }".colorize(:yellow).to_s
                # puts "--------------"
                # begin 
                #     db.query "select username.username, password.password, passwords_sprayed.date_time, passwords_sprayed.spraytype
                #     from username, password, passwords_sprayed
                #     where 
                #     username.usernameid = passwords_sprayed.usernameid
                #     and 
                #     password.passwordid = passwords_sprayed.passwordid;" do |rs|
                #         rs.each do
                #             line = "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String)} | #{rs.read(String)}" 
                #             puts line if line.downcase.includes? ans.downcase.strip.split(" ").map(&.strip)[1].downcase
                #         end
                #     end
                # rescue  e 
                #     puts "Error: #{e.message}"
                # end
                # puts ""
                # puts ""

                table = Tallboy.table do
                    header ["Username", "Password","TimeStamp","SprayType" ]
                    begin 
                        db.query "select username.username, password.password, passwords_sprayed.date_time, passwords_sprayed.spraytype
                        from username, password, passwords_sprayed
                        where 
                        username.usernameid = passwords_sprayed.usernameid
                        and 
                        password.passwordid = passwords_sprayed.passwordid;" do |rs|
                            rs.each do
                                line = "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String)} | #{rs.read(String)}" 
                                row line.split("|").map(&.strip()) if line.downcase.includes? ans.downcase.strip.split(" ").map(&.strip)[1].downcase
                            end
                        end
                    rescue  e 
                        puts "Error: #{e.message}"
                    end
                    
                end
                puts table 



            end

        end

    



    end


end 



