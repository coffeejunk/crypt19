# coding: ASCII
class String
  if RUBY_VERSION =~ /1\.8/
    def getbyte(index)
      self[index]
    end
  end

  if RUBY_VERSION =~ /1\.8/ && RUBY_VERSION != '1.8.7'
    def bytes
      bytes = []
      self.each_byte {|b| bytes << b}
      bytes
    end
  end
end
