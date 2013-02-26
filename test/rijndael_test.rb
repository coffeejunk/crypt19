require 'test/unit'
require 'crypt/rijndael'
require 'fileutils'

class TestRijndael < Test::Unit::TestCase

  def test_init
  assert_raise(RuntimeError) {
      rijndael = Crypt::Rijndael.new("Who is this John Galt guy, anyway?", 64)
    }
  assert_raise(RuntimeError) {
      rijndael = Crypt::Rijndael.new("Who is this John Galt guy, anyway?", 128, 64)
    }
  end

  def test_block_size
    rijndael = Crypt::Rijndael.new("Who is this John Galt guy, anyway?", 128, 256)
    assert_equal(32, rijndael.block_size)
    rijndael = Crypt::Rijndael.new("Who is this John Galt guy, anyway?", 256, 128)
    assert_equal(16, rijndael.block_size)
  end

  def test_block
    rijndael = Crypt::Rijndael.new("Who is this John Galt guy, anyway?", 128, 128)
    block = "\341q\214NIj\023u\343\330s\323\354$g\277"
    encrypted_block = rijndael.encrypt_block(block)
    assert_equal("\024\246^\332T\323x`\323yB\352\2159\212R", encrypted_block)
    decrypted_block = rijndael.decrypt_block(encrypted_block)
    assert_equal(block, decrypted_block)
    rijndael = Crypt::Rijndael.new("Who is this John Galt guy, anyway?", 128, 256)
    assert_raise(RuntimeError) {
      encrypted_block = rijndael.encrypt_block(block)
    }
  end
	
  def test_string
    rijndael = Crypt::Rijndael.new("Who is this John Galt guy, anyway?")
    string = "This is a string which is not a multiple of 8 characters long"
    encrypted_string = rijndael.encrypt_string(string)
    decrypted_string = rijndael.decrypt_string(encrypted_string)
    assert_equal(string, decrypted_string)
  end

  def test_file
    plain_text = "This is a multi-line string\nwhich is not a multiple of 8 \ncharacters long."
    plain_file = File.new('plain.txt', 'wb+')
    plain_file.puts(plain_text)
    plain_file.close()
    rijndael = Crypt::Rijndael.new("Who is this John Galt guy, anyway?")
    rijndael.encrypt_file('plain.txt', 'crypt.txt')
    rijndael.decrypt_file('crypt.txt', 'decrypt.txt')
    decrypt_file = File.new('decrypt.txt', 'rb')
    decrypt_text = decrypt_file.readlines().join('').chomp()
    decrypt_file.close()
    assert_equal(plain_text, decrypt_text)
    FileUtils.rm('plain.txt')
    FileUtils.rm('crypt.txt')
    FileUtils.rm('decrypt.txt')
  end

end
