require 'stringio'
require 'crypt/stringxor'

module Crypt
  module CBC

    ULONG = 0x100000000

    # When this module is mixed in with an encryption class, the class
    # must provide three methods: encrypt_block(block) and decrypt_block(block)
    # and block_size()


    def generate_initialization_vector(words)
      srand(Time.now.to_i)
      vector = ""
      words.times {
        vector << [rand(ULONG)].pack('N')
      }
      return(vector)
    end


    def encrypt_stream(plain_stream, crypt_stream)
      # Cypher-block-chain mode

      init_vector = generate_initialization_vector(block_size() / 4)
      chain = encrypt_block(init_vector)
      crypt_stream.write(chain)

      while ((block = plain_stream.read(block_size())) && (block.length == block_size()))
        block = block ^ chain
        encrypted = encrypt_block(block)
        crypt_stream.write(encrypted)
        chain = encrypted
      end

      # write the final block
      # At most block_size()-1 bytes can be part of the message.
      # That means the final byte can be used to store the number of meaningful
      # bytes in the final block
      block = '' if block.nil?
      buffer = block.split('')
      remaining_message_bytes = block_size() - buffer.length
      buffer << remaining_message_bytes.chr * remaining_message_bytes
      block = buffer.join('')
      block = block ^ chain
      encrypted = encrypt_block(block)
      crypt_stream.write(encrypted)
    end


    def decrypt_stream(crypt_stream, plain_stream)
      # Cypher-block-chain mode
      chain = crypt_stream.read(block_size())

      while (block = crypt_stream.read(block_size()))
        decrypted = decrypt_block(block)
        plain_text = decrypted ^ chain
        plain_stream.write(plain_text) unless crypt_stream.eof?
        chain = block
      end

      # write the final block, omitting the padding
      buffer = plain_text.split('')
      remaining_message_bytes = block_size() - buffer.last.unpack('C').first
      remaining_message_bytes.times { plain_stream.write(buffer.shift) }
    end


    def carefully_open_file(filename, mode)
      begin
        a_file = File.new(filename, mode)
      rescue
        puts "Sorry. There was a problem opening the file <#{filename}>."
        a_file.close() unless a_file.nil?
        raise
      end
      return(a_file)
    end


    def encrypt_file(plain_filename, crypt_filename)
      plain_file = carefully_open_file(plain_filename, 'rb')
      crypt_file = carefully_open_file(crypt_filename, 'wb+')
      encrypt_stream(plain_file, crypt_file)
      plain_file.close unless plain_file.closed?
      crypt_file.close unless crypt_file.closed?
    end


    def decrypt_file(crypt_filename, plain_filename)
      crypt_file = carefully_open_file(crypt_filename, 'rb')
      plain_file = carefully_open_file(plain_filename, 'wb+')
      decrypt_stream(crypt_file, plain_file)
      crypt_file.close unless crypt_file.closed?
      plain_file.close unless plain_file.closed?
    end


    def encrypt_string(plain_text)
      plain_stream = StringIO.new(plain_text)
      crypt_stream = StringIO.new('')
      encrypt_stream(plain_stream, crypt_stream)
      crypt_text = crypt_stream.string
      return(crypt_text)
    end


    def decrypt_string(crypt_text)
      crypt_stream = StringIO.new(crypt_text)
      plain_stream = StringIO.new('')
      decrypt_stream(crypt_stream, plain_stream)
      plain_text = plain_stream.string
      return(plain_text)
    end

  end
end
