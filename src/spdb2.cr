require "sqlite3"
require "cryprompt"
require "option_parser"

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
clear:
  _description: Clears the screen
help: 
  _description: Prints the help screen
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
        case ans.downcase.strip  
        when "clear"
            system("clear")
        when "usernames"
            puts "Usernames"
            puts "---------------------------"
            begin
                db.query "select * from username;" do |rs|
                    rs.each do
                        puts "#{rs.read(Int32)} | #{rs.read(String)}"
                    end
                end
            rescue  e
                puts "Error: #{e.message}"
            end
        when "passwords"
            puts "Sprayed Passwords"
            puts "---------------------------"
            begin 
                db.query "select * from password;" do |rs|
                    rs.each do
                        puts "#{rs.read(Int32)} | #{rs.read(String)}"
                    end
                end
            rescue  e 
                puts "Error: #{e.message}"
            end
        when "valid", "creds"
            puts "Valid Credentials!"
            puts "---------------------------"
            begin 
                db.query "select username.username, password.password , valid_passwords.date_time
                from username, password, valid_passwords
                where 
                username.usernameid = valid_passwords.usernameid
                and 
                password.passwordid = valid_passwords.passwordid;" do |rs|
                    rs.each do
                        puts "#{rs.read(String)} | #{rs.read(String)} | #{rs.read(String)}"
                    end
                end
            rescue  e 
                puts "Error: #{e.message}"
            end
    
    
    
        when "sprayed"
            puts "Sprayed history"
            puts "---------------------------"
            begin 
                db.query "select username.username, password.password, passwords_sprayed.date_time
                from username, password, passwords_sprayed
                where 
                username.usernameid = passwords_sprayed.usernameid
                and 
                password.passwordid = passwords_sprayed.passwordid;" do |rs|
                    rs.each do
                        puts "#{rs.read(String)} | #{rs.read(String)} | #{ rs.read(String) }"
                    end
                end
            rescue  e 
                puts "Error: #{e.message}"
            end
    
    
    
    
    
    
    
    
    
    
    
    
            ######################### export features ############################
        when "export sprayed"
            puts "Exporting SPRAYED to exported_spdb_sprayed.csv ... "
            File.delete("./exported_spdb_sprayed.csv") if File.exists? "./exported_spdb_sprayed.csv"
            file = File.new("./exported_spdb_sprayed.csv", "w")
            file.puts "Username,Password,Time"
            begin 
                db.query "select username.username, password.password, passwords_sprayed.date_time
                from username, password, passwords_sprayed
                where 
                username.usernameid = passwords_sprayed.usernameid
                and 
                password.passwordid = passwords_sprayed.passwordid;" do |rs|
                    rs.each do
                        line = "#{rs.read(String)},#{rs.read(String)},#{ rs.read(String) }"
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
        when "export valid"
            puts "Exporting VALID to exported_spdb_valid.csv ... "
            File.delete("./exported_spdb_valid.csv") if File.exists? "./exported_spdb_valid.csv"
            file = File.new("./exported_spdb_valid.csv", "w")
            file.puts "Username,Password,Time"
            begin 
                db.query "select username.username, password.password , valid_passwords.date_time
                from username, password, valid_passwords
                where 
                username.usernameid = valid_passwords.usernameid
                and 
                password.passwordid = valid_passwords.passwordid;" do |rs|
                    rs.each do
                        line = "#{rs.read(String)},#{rs.read(String)},#{ rs.read(String) }"
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
    
        when "help"
            puts "help  usernames  passwords  valid  sprayed  export"
        end
    end


end 



