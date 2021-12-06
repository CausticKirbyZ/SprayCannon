




#
#
#
#
#
#
# this is expiramental and does not work at all!!! i will most likely move this to a seperate library!! 
#
#
#
#
#
#
#
#
#
#
#











require "socket"
require "bit_array"

module SMBlib
    class SMB
        def login_smb2(target)
            sock = Socket.tcp(Socket::Family::INET)
            sock.connect(target,445)
            pack = Smb2_packet_sync.new()
            pack.protocolid = Bytes[0x42, 0x4D, 0x53, 0xFE] # smb hopefully 
            sock.send(pack)
        end
    end
    
    class Packet
    end

    # class SMB2_Packet_sync
    #     # packet structure according to msft smb2 rfc 
    #     protocolid = BitArray.new(32) # 32 bits
    #     structuresize = BitArray.new(16) # 16 bits
    #     creditCharge = BitArray.new(16) # 16 bits 
    #     channelsequence_reserved_status = BitArray.new(32) # 32 bits 
    #     command = BitArray.new(16) # 16 bits 
    #     creditrequest_creditresponse = BitArray.new(16) # 16 bits 
    #     flags = BitArray.new(32) # 32 bits 
    #     nextcommand = BitArray.new(32) # 32 bits 
    #     messageid = BitArray.new(32) # 32 bits 
    #     reserved = BitArray.new(32) # 32 bits  
    #     treeid = BitArray.new(32) # 32 bits
    #     sessionid = BitArray.new(64) # 64 bits or 8 bytes
    #     signature = BitArray.new(128) # 128 bits or 16 bytes
    # end

    class Smb2_packet_sync
        # packet structure according to msft smb2 rfc 
        property protocolid : Slice(UInt8) #Slice(UInt32|UInt64|UInt16|UInt8|UInt128)
        # def initialize
        #     @protocolid = Bytes.new(4) # 32 bits
        #     @structuresize = Bytes.new(2) # 16 bits
        #     @creditCharge = Bytes.new(2) # 16 bits 
        #     @channelsequence_reserved_status = Bytes.new(4) # 32 bits 
        #     @command = Bytes.new(4) # 16 bits 
        #     @creditrequest_creditresponse = Bytes.new(2) # 16 bits 
        #     @flags = Bytes.new(4) # 32 bits 
        #     @nextcommand = Bytes.new(4) # 32 bits 
        #     @messageid = Bytes.new(4) # 32 bits 
        #     @reserved = Bytes.new(4) # 32 bits  
        #     @treeid = Bytes.new(4) # 32 bits
        #     @sessionid = Bytes.new(8) # 64 bits or 8 bytes
        #     @signature = Bytes.new(16) # 128 bits or 16 bytes
        # end
        def initialize
            @protocolid = [ 0x42_u8, 0x4D_8, 0x53_u8, 0xFE_u8 ] # 32 bits
            @structuresize = [] # 2 bytes = 16 bits
            @creditCharge =[] # 16 bits 
            @channelsequence_reserved_status = [] # 32 bits 
            @command = [] # 16 bits 
            @creditrequest_creditresponse = [] # 16 bits 
            @flags = [] # 32 bits 
            @nextcommand = [] # 32 bits 
            @messageid = [] # 32 bits 
            @reserved = [] # 32 bits  
            @treeid = [] # 32 bits
            @sessionid = [] # 64 bits or 8 bytes
            @signature = [] # 128 bits or 16 bytes
        end

        def arr_to_slice(arr)
            Slice.new(arr.size) {|i| arr[i]}
        end

        def to_slice()
            a = @protocolid + @structuresize + @creditCharge + @channelsequence_reserved_status + @command + @creditrequest_creditresponse + @flags + @nextcommand + @messageid + @reserved + @treeid + @sessionid + @signature
            return ar_to_slice( a )
        end
    end


end