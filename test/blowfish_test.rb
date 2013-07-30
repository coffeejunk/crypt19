# coding: ASCII
require 'test/unit'
require 'crypt/blowfish'
require 'crypt/cbc'
require 'fileutils'

class TestBlowfish < Test::Unit::TestCase

  def setup
     @bf = Crypt::Blowfish.new("Who is John Galt?")  # Schneier's test key
  end

  def test_block_size
    assert_equal(8, @bf.block_size(), "Wrong block size")
  end

  def test_initialize
    assert_raise(RuntimeError) {
      b0 = Crypt::Blowfish.new("")
    }
    assert_nothing_raised() {
      b1 = Crypt::Blowfish.new("1")
    }
    assert_nothing_raised() {
      b56 = Crypt::Blowfish.new("1"*56)
    }
    assert_raise(RuntimeError) {
      b57 = Crypt::Blowfish.new("1"*57)
    }
  end

  def test_pair
    bf = Crypt::Blowfish.new("Who is John Galt?")
    orig_l, orig_r = [0xfedcba98, 0x76543210]
    l, r = bf.encrypt_pair(orig_l, orig_r)
    assert_equal(0xcc91732b, l)
    assert_equal(0x8022f684, r)
    l, r = bf.decrypt_pair(l, r)
    assert_equal(orig_l, l)
    assert_equal(orig_r, r)
  end

  def test_block
    bf = Crypt::Blowfish.new("Who is John Galt?")
    block = "norandom"
    encrypted_block = bf.encrypt_block(block)
    assert_equal("\236\353k\321&Q\"\220", encrypted_block)
    decrypted_block = bf.decrypt_block(encrypted_block)
    assert_equal(block, decrypted_block)
  end

  def test_string
    length = 30 + rand(26)
    userkey = ""
    length.times { userkey << rand(256).chr }
    bf = Crypt::Blowfish.new(userkey)
    string = "This is a string which is not a multiple of 8 characters long"
    encrypted_string = bf.encrypt_string(string)
    decrypted_string = bf.decrypt_string(encrypted_string)
    assert_equal(string, decrypted_string)
    secondstring = "This is another string to check repetitive use."
    encrypted_string = bf.encrypt_string(secondstring)
    decrypted_string = bf.decrypt_string(encrypted_string)
    assert_equal(secondstring, decrypted_string)

  end

  def test_file
    plain_text = "This is a multi-line string\nwhich is not a multiple of 8 \ncharacters long."
    plain_file = File.new('plain.txt', 'wb+')
    plain_file.puts(plain_text)
    plain_file.close()
    bf = Crypt::Blowfish.new("Who is John Galt?")
    bf.encrypt_file('plain.txt', 'crypt.txt')
    bf.decrypt_file('crypt.txt', 'decrypt.txt')
    decrypt_file = File.new('decrypt.txt', 'rb')
    decrypt_text = decrypt_file.readlines().join('').chomp()
    decrypt_file.close()
    assert_equal(plain_text, decrypt_text)
    FileUtils.rm('plain.txt')
    FileUtils.rm('crypt.txt')
    FileUtils.rm('decrypt.txt')
  end

end
