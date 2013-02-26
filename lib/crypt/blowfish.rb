#  Blowfish algorithm by Bruce Schneider
#  Ported from the reference C code

require 'crypt/cbc'
require 'crypt/blowfish-tables'
require 'crypt/bytes-compat'

module Crypt
  class Blowfish

    include Crypt::CBC
    include Crypt::BlowfishTables

    ULONG = 0x100000000

    def block_size
      return(8)
    end


    def initialize(key)
      @key = key
      raise "Bad key length: the key must be 1-56 bytes." unless (key.length.between?(1,56))
      @p_array = []
      @s_boxes = []
      setup_blowfish()
    end


    def f(x)
      a, b, c, d = [x].pack('N').unpack('CCCC')
      y = (@s_boxes[0][a] + @s_boxes[1][b]) % ULONG
      y = (y ^ @s_boxes[2][c]) % ULONG
      y = (y + @s_boxes[3][d]) % ULONG
      return(y)
    end


    def setup_blowfish()
      @s_boxes = Array.new(4) { |i| INITIALSBOXES[i].clone }
      @p_array = INITIALPARRAY.clone
      keypos = 0
      0.upto(17) { |i|
        data = 0
        4.times {
          data = ((data << 8) | @key.getbyte(keypos)) % ULONG
          keypos = (keypos.next) % @key.length
        }
        @p_array[i] = (@p_array[i] ^ data) % ULONG
      }
      l = 0
      r = 0
      0.step(17, 2) { |i|
        l, r = encrypt_pair(l, r)
        @p_array[i]   = l
        @p_array[i+1] = r
      }
      0.upto(3) { |i|
        0.step(255, 2) { |j|
          l, r = encrypt_pair(l, r)
          @s_boxes[i][j]   = l
          @s_boxes[i][j+1] = r
        }
      }
    end

    def encrypt_pair(xl, xr)
      0.upto(15) { |i|
          xl = (xl ^ @p_array[i]) % ULONG
          xr = (xr ^ f(xl)) % ULONG
          xl, xr = xr, xl
      }
      xl, xr = xr, xl
      xr = (xr ^ @p_array[16]) % ULONG
      xl = (xl ^ @p_array[17]) % ULONG
      return([xl, xr])
    end


    def decrypt_pair(xl, xr)
      17.downto(2) { |i|
          xl = (xl ^ @p_array[i]) % ULONG
          xr = (xr ^ f(xl)) % ULONG
          xl, xr = xr, xl
      }
      xl, xr = xr, xl
      xr = (xr ^ @p_array[1]) % ULONG
      xl = (xl ^ @p_array[0]) % ULONG
      return([xl, xr])
    end


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
end
