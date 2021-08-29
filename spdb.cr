require "sqlite3"


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

# maybe implement a timeline feature ???? start is below.... idk how it would work....                                                        
# db.exec "create table if not exists timeline(   timeline_id integer not null, 
#                                                 password_id integer not null, 
#                                                 date_time date, 
#                                                 primary key(timeline_id, password_id )
#  )


# "



print "> "
while x = gets 
    case x.downcase.strip
    when "exit"
        exit 0
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
    when "valid"
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





    when "help"
        puts "help  usernames  passwords  valid  sprayed"
    end


    print "> "
end





# insert into password(password) values ("password1") ;
# insert into password(password) values ("password2") ;
# insert into password(password) values ("password3") ;
# insert into username(username) values ("username1") ;
# insert into username(username) values ("username2") ;
# insert into username(username) values ("username3") ;
# insert into passwords_sprayed values (1,1);      
# insert into passwords_sprayed values (1,2); 
# insert into passwords_sprayed values (2,2);
# insert into passwords_sprayed values (3,1); 
# insert into valid_passwords values (2,2); 