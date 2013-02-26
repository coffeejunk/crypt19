require 'test/unit'
require 'crypt/idea'
require 'fileutils'

class TestIdea < Test::Unit::TestCase

  def test_init
  assert_nothing_raised(RuntimeError) {
      idea_en = Crypt::IDEA.new("Who was John Galt and where's my breakfast?", Crypt::IDEA::ENCRYPT)  
    }
  end
    
  def test_block_size
    idea_en = Crypt::IDEA.new("Who is John Galt", Crypt::IDEA::ENCRYPT) 
    assert_equal(8, idea_en.block_size(), "Wrong block size")
  end

  def test_pair
    idea_en = Crypt::IDEA.new("Who is John Galt", Crypt::IDEA::ENCRYPT) 
    orig_l, orig_r = [0xfedcba98, 0x76543210] 
    l, r = idea_en.crypt_pair(orig_l, orig_r)
    assert_equal(0x05627e79, l)
    assert_equal(0x69476521, r)
    idea_de = Crypt::IDEA.new("Who is John Galt", Crypt::IDEA::DECRYPT) 
    l, r = idea_de.crypt_pair(l, r)
    assert_equal(orig_l, l)
    assert_equal(orig_r, r)
  end

  def test_block
    idea_en = Crypt::IDEA.new("Who is John Galt", Crypt::IDEA::ENCRYPT) 
    block = "norandom"
    encrypted_block = idea_en.encrypt_block(block)
    assert_equal("\235\003\326u\001\330\361\t", encrypted_block)
    idea_de = Crypt::IDEA.new("Who is John Galt", Crypt::IDEA::DECRYPT) 
    decrypted_block = idea_de.decrypt_block(encrypted_block)
    assert_equal(block, decrypted_block)
  end
	
  def test_string
    length = 25 + rand(12)
    userkey = ""
    length.times { userkey << rand(256).chr }
    idea_en = Crypt::IDEA.new(userkey, Crypt::IDEA::ENCRYPT) 
    string = "This is a string which is not a multiple of 8 characters long"
    encrypted_string = idea_en.encrypt_string(string)
    idea_de = Crypt::IDEA.new(userkey, Crypt::IDEA::DECRYPT) 
    decryptedString = idea_de.decrypt_string(encrypted_string)
    assert_equal(string, decryptedString)
  end
  
  def test_file
    plain_text = "This is a multi-line string\nwhich is not a multiple of 8 \ncharacters long."
    plain_file = File.new('plain.txt', 'wb+')
    plain_file.puts(plain_text)
    plain_file.close()
    idea_en = Crypt::IDEA.new("Who is John Galt", Crypt::IDEA::ENCRYPT) 
    idea_en.encrypt_file('plain.txt', 'crypt.txt')
    idea_de = Crypt::IDEA.new("Who is John Galt", Crypt::IDEA::DECRYPT) 
    idea_de.decrypt_file('crypt.txt', 'decrypt.txt')
    decrypt_file = File.new('decrypt.txt', 'rb')
    decrypt_text = decrypt_file.readlines().join('').chomp()
    decrypt_file.close()
    assert_equal(plain_text, decrypt_text)
    FileUtils.rm('plain.txt')
    FileUtils.rm('crypt.txt')
    FileUtils.rm('decrypt.txt')
  end

end