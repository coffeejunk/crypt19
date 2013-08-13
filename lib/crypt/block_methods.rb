module BlockMethods
    def encrypt_block(block)
      xl, xr = block.unpack('NN')
      xl, xr = encrypt_pair(xl, xr)
      encrypted = [xl, xr].pack('NN')
      return(encrypted)
    end


    def decrypt_block(block)
      xl, xr = block.unpack('NN')
      xl, xr = decrypt_pair(xl, xr)
      decrypted = [xl, xr].pack('NN')
      return(decrypted)
    end
end
