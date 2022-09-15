def check_version() : String 
    puts "Checking for updates..."
    # do a check here will return a VERSION = "1.1.1" string 
    # web request to the version file on github 
    version = HTTP::Client.get("https://raw.githubusercontent.com/CausticKirbyZ/SprayCannon/main/src/helpers/VERSION.cr").body
    return version.split("=").last.delete("\"").strip()
end