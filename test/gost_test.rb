# coding: ASCII
require 'test/unit'
require 'crypt/gost'
require 'fileutils'

class TestGost < Test::Unit::TestCase

  def test_init
  assert_nothing_raised(RuntimeError) {
      gost = Crypt::Gost.new("Whatever happened to Yuri Gagarin?")
    }
  assert_nothing_raised(RuntimeError) {
      gost = Crypt::Gost.new("Whatever happened to Yuri?")
    }
  end

  def test_block_size
    gost = Crypt::Gost.new("Whatever happened to Yuri?")
    assert_equal(8, gost.block_size(), "Wrong block size")
  end

  def test_pair
    gost = Crypt::Gost.new("Whatever happened to Yuri?")
    orig_l, orig_r = [0xfedcba98, 0x76543210]
    l, r = gost.encrypt_pair(orig_l, orig_r)
    assert_equal(0xaefaf8f4, l)
    assert_equal(0xe24891b0, r)
    l, r = gost.decrypt_pair(l, r)
    assert_equal(orig_l, l)
    assert_equal(orig_r, r)
  end

  def test_block
    gost = Crypt::Gost.new("Whatever happened to Yuri?")
    block = "norandom"
    encrypted_block = gost.encrypt_block(block)
    assert_equal(".Vy\377\005\e3`", encrypted_block)
    decrypted_block = gost.decrypt_block(encrypted_block)
    assert_equal(block, decrypted_block)
  end

  def test_string
    length = 25 + rand(12)
    userkey = ""
    length.times { userkey << rand(256).chr }
    gost = Crypt::Gost.new(userkey)
    string = "This is a string which is not a multiple of 8 characters long"
    encrypted_string = gost.encrypt_string(string)
    decrypted_string = gost.decrypt_string(encrypted_string)
    assert_equal(string, decrypted_string)
  end

  def test_file
    plain_text = "This is a multi-line string\nwhich is not a multiple of 8 \ncharacters long."
    plain_file = File.new('plain.txt', 'wb+')
    plain_file.puts(plain_text)
    plain_file.close()
    gost = Crypt::Gost.new("Whatever happened to Yuri?")
    gost.encrypt_file('plain.txt', 'crypt.txt')
    gost.decrypt_file('crypt.txt', 'decrypt.txt')
    decrypt_file = File.new('decrypt.txt', 'rb')
    decrypt_text = decrypt_file.readlines().join('').chomp()
    decrypt_file.close()
    assert_equal(plain_text, decrypt_text)
    FileUtils.rm('plain.txt')
    FileUtils.rm('crypt.txt')
    FileUtils.rm('decrypt.txt')
  end

end
