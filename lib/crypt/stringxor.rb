module Crypt
  module StringXor

    def ^(a_string)
      a = self.unpack('C'*(self.length))
      b = a_string.unpack('C'*(a_string.length))
      if (b.length < a.length)
        (a.length - b.length).times { b << 0 }
      end
      xor = ""
      0.upto(a.length-1) { |pos|
        x = a[pos] ^ b[pos]
        xor << x.chr()
      }
      return(xor)
    end

  end
end

class String
  include Crypt::StringXor
end
