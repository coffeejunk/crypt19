#  RC6 symmetric key block cipher
#  RC6 is a patented encryption algorithm (U.S. Patent 5,724,428 and U.S. Patent 5,835,600)
#  Ported by Alexey Lapitsky <lex.public@gmail.com> (2009)

require 'crypt/cbc'

module Crypt
  class RC6
    include Crypt::CBC

    def block_size
      return 16
    end

    def lrotate(d,s)
      d = d & 0xffffffff
      ((d)<<(s&(31))) | ((d)>>(32-(s&(31))))
    end
    def rrotate(d,s)
      d = d & 0xffffffff
      ((d)>>(s&(31))) | ((d)<<(32-(s&(31))))
    end

    def initialize(key)
      @rounds, @sbox, @key = 20, [0xB7E15163], []
      key = key.bytes.to_a if key.class == String
      raise("Wrong key length") unless [32,24,16].include?(key.size)
      (key.size-1).downto(0){|i| @key[i/4] = ((@key[i/4]||0) << 8) + key[i]}

      (@rounds * 2 + 3).times{|i| @sbox << (@sbox.last + 0x9E3779B9 & 0xffffffff)}
      a = b = i = j = 0
      (3 * (2 * @rounds + 4)).times do
        a = @sbox[i] = lrotate(@sbox[i] + a + b, 3)
        b = @key[j] = lrotate(@key[j] + a + b, a + b)
        i = (i + 1).divmod(2 * @rounds + 4).last
        j = (j + 1).divmod(@key.size).last
      end
    end

    def encrypt_block(data)
      a, b, c, d = *data.unpack('N*')
      b += @sbox[0]
      d += @sbox[1]
      1.upto @rounds do |i|
        t = lrotate((b * (2 * b + 1)), 5)
        u = lrotate((d * (2 * d + 1)), 5)
        a = lrotate((a ^ t), u) + @sbox[2 * i]
        c = lrotate((c ^ u), t) + @sbox[2 * i + 1]
        a, b, c, d  =  b, c, d, a
      end
      a += @sbox[2 * @rounds + 2]
      c += @sbox[2 * @rounds + 3]
      [a, b, c, d].map{|i| i & 0xffffffff}.pack('N*')
    end

    def decrypt_block(data)
      a, b, c, d = *data.unpack('N*')
      c -= @sbox[2 * @rounds + 3]
      a -= @sbox[2 * @rounds + 2]
      @rounds.downto 1 do |i|
        a, b, c, d = d, a, b, c
        u = lrotate((d * (2 * d + 1)), 5)
        t = lrotate((b * (2 * b + 1)), 5)
        c = rrotate((c - @sbox[2 * i + 1]), t) ^ u
        a = rrotate((a - @sbox[2 * i]), u) ^ t
      end
      d -= @sbox[1]
      b -= @sbox[0]
      [a, b, c, d].map{|i| i & 0xffffffff}.pack('N*')
    end

  end
end
