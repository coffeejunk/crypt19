# coding: ASCII-8BIT
# Adapted from the reference C implementation:
#   rijndael-alg-ref.c   v2.2   March 2002
#   Reference ANSI C code by Paulo Barreto and Vincent Rijmen

require 'crypt/cbc'
require 'crypt/rijndael-tables'
require 'crypt/bytes-compat'

module Crypt
  class Rijndael

    include Crypt::CBC
    include Crypt::RijndaelTables


    def initialize(user_key, key_bits = 256, block_bits = 128)
      case key_bits
        when 128
          @key_words = 4
        when 192
          @key_words = 6
        when 256
          @key_words = 8
        else raise "The key must be 128, 192, or 256 bits long."
      end

      case (key_bits >= block_bits) ? key_bits : block_bits
        when 128
          @rounds = 10
        when 192
          @rounds = 12
        when 256
          @rounds = 14
        else raise "The key and block sizes must be 128, 192, or 256 bits long."
      end

      case block_bits
        when 128
          @block_size = 16
          @block_words = 4
          @shift_index = 0
        when 192
          @block_size = 24
          @block_words = 6
          @shift_index = 1
        when 256
          @block_size = 32
          @block_words = 8
          @shift_index = 2
        else raise "The block size must be 128, 192, or 256 bits long."
      end

      uk = user_key.unpack('C'*user_key.length)
      max_useful_size_of_user_key = (key_bits/8)
      uk = uk[0..max_useful_size_of_user_key-1]    # truncate
      padding = 0
      if (user_key.length < key_bits/8)
        shortfall_in_user_key = (key_bits/8 - user_key.length)
        shortfall_in_user_key.times { uk << padding }
      end
      @key = [[], [], [], []]
      0.upto(uk.length-1) { |pos|
        @key[pos % 4][pos / 4] = uk[pos]
      }
      @round_keys = generate_key_schedule(@key, key_bits, block_bits)
    end


    def block_size
      return(@block_size) # needed for CBC
    end


    def mul(a, b)
      if ((a ==0) | (b == 0))
        result = 0
      else
        result = AlogTable[(LogTable[a] + LogTable[b]) % 255]
      end
      return(result)
    end


    def add_round_key(block_array, round_key)
    0.upto(3) { |i|
      0.upto(@block_words) { |j|
        block_array[i][j] ^= round_key[i][j]
      }
    }
    return(block_array)
    end


    def shift_rows(block_array, direction)
      tmp = []
      1.upto(3) { |i|  # row zero remains unchanged
        0.upto(@block_words-1) { |j|
          tmp[j] = block_array[i][(j + Shifts[@shift_index][i][direction]) % @block_words]
        }
        0.upto(@block_words-1) { |j|
          block_array[i][j] = tmp[j]
        }
      }
      return(block_array)
    end


    def substitution(block_array, sBox)
      # replace every byte of the input with the byte at that position in the S-box
      0.upto(3) { |i|
        0.upto(@block_words-1) { |j|
          block_array[i][j] = sBox[block_array[i][j]]
        }
      }
      return(block_array)
    end


    def mix_columns(block_array)
      mixed = [[], [], [], []]
      0.upto(@block_words-1) { |j|
        0.upto(3) { |i|
          mixed[i][j] = mul(2,block_array[i][j]) ^
            mul(3,block_array[(i + 1) % 4][j]) ^
            block_array[(i + 2) % 4][j] ^
            block_array[(i + 3) % 4][j]
        }
      }
      return(mixed)
    end


    def inverse_mix_columns(block_array)
      unmixed = [[], [], [], []]
      0.upto(@block_words-1) { |j|
        0.upto(3) { |i|
          unmixed[i][j] = mul(0xe, block_array[i][j]) ^
            mul(0xb, block_array[(i + 1) % 4][j]) ^
            mul(0xd, block_array[(i + 2) % 4][j]) ^
            mul(0x9, block_array[(i + 3) % 4][j])
        }
      }
       return(unmixed)
    end


    def generate_key_schedule(k, key_bits, block_bits)
      tk = k[0..3][0..@key_words-1]  # using slice to get a copy instead of a reference
      key_sched = []
      (@rounds + 1).times { key_sched << [[], [], [], []] }
      t = 0
      j = 0
      while ((j < @key_words) && (t < (@rounds+1)*@block_words))
        0.upto(3) { |i|
          key_sched[t / @block_words][i][t % @block_words] = tk[i][j]
        }
        j += 1
        t += 1
      end
      # while not enough round key material collected, calculate new values
      rcon_index = 0
      while (t < (@rounds+1)*@block_words)
        0.upto(3) { |i|
          tk[i][0] ^= S[tk[(i + 1) % 4][@key_words - 1]]
        }
        tk[0][0] ^= Rcon[rcon_index]
        rcon_index = rcon_index.next
        if (@key_words != 8)
          1.upto(@key_words - 1) { |j|
            0.upto(3) { |i|
              tk[i][j] ^= tk[i][j-1];
            }
          }
        else
          1.upto(@key_words/2 - 1) { |j|
            0.upto(3) { |i|
              tk[i][j] ^= tk[i][j-1]
            }
          }
          0.upto(3) { |i|
            tk[i][@key_words/2] ^= S[tk[i][@key_words/2 - 1]]
          }
          (@key_words/2 + 1).upto(@key_words - 1) { |j|
            0.upto(3) { |i|
              tk[i][j] ^= tk[i][j-1]
            }
          }
        end
        j = 0
        while ((j < @key_words) && (t < (@rounds+1) * @block_words))
          0.upto(3) { |i|
            key_sched[t / @block_words][i][t % @block_words] = tk[i][j]
          }
          j += 1
          t += 1
        end
      end
      return(key_sched)
    end


    def encrypt_byte_array(block_array)
      block_array = add_round_key(block_array, @round_keys[0])
      1.upto(@rounds - 1) { |round|
        block_array = substitution(block_array, S)
        block_array = shift_rows(block_array, 0)
        block_array = mix_columns(block_array)
        block_array = add_round_key(block_array, @round_keys[round])
      }
      # special round without mix_columns
      block_array = substitution(block_array,S)
      block_array = shift_rows(block_array,0)
      block_array = add_round_key(block_array, @round_keys[@rounds])
      return(block_array)
    end


    def encrypt_block(block)
      raise "block must be #{@block_size} bytes long" if (block.length() != @block_size)
      block_array = [[], [], [], []]
      block_bytes = block.bytes.to_a
      0.upto(@block_size - 1) { |pos|
        block_array[pos % 4][pos / 4] = block_bytes[pos]
      }
      encrypted_block = encrypt_byte_array(block_array)
      encrypted = ""
      0.upto(@block_size - 1) { |pos|
        encrypted << encrypted_block[pos % 4][pos / 4]
      }
      return(encrypted)
    end


    def decrypt_byte_array(block_array)
      # first special round without inverse_mix_columns
      # add_round_key is an involution - applying it a second time returns the original result
      block_array = add_round_key(block_array, @round_keys[@rounds])
      block_array = substitution(block_array,Si)   # using inverse S-box
      block_array = shift_rows(block_array,1)
      (@rounds-1).downto(1) { |round|
        block_array = add_round_key(block_array, @round_keys[round])
        block_array = inverse_mix_columns(block_array)
        block_array = substitution(block_array, Si)
        block_array = shift_rows(block_array, 1)
      }
      block_array = add_round_key(block_array, @round_keys[0])
      return(block_array)
    end


    def decrypt_block(block)
      raise "block must be #{@block_size} bytes long" if (block.length() != @block_size)
      block_array = [[], [], [], []]
      block_bytes = block.bytes.to_a
      0.upto(@block_size - 1) { |pos|
        block_array[pos % 4][pos / 4] = block_bytes[pos]
      }
      decrypted_block = decrypt_byte_array(block_array)
      decrypted = ""
      0.upto(@block_size - 1) { |pos|
        decrypted << decrypted_block[pos % 4][pos / 4]
      }
      return(decrypted)
    end

  end
end
