# add_noise - take a message and intersperse noise to make a new noisy message of given byte-length
# remove_noise - take a noisy message and extract the message

module Crypt
  module Noise

    def add_noise(new_length)
      message = self
      usable_noisy_message_length = new_length / 9 * 8
      bitmap_size = new_length / 9
      remaining_bytes = new_length - usable_noisy_message_length - bitmap_size
      if (message.length > usable_noisy_message_length)
        minimumnew_length = (message.length / 8.0).ceil * 9
        puts "For a clear text of #{message.length} bytes, the minimum obscured length"
        puts "is #{minimumnew_length} bytes which allows for no noise in the message."
        puts "You should choose an obscured length of at least double the clear text"
        puts "length, such as #{message.length / 8 * 32} bytes"
        raise "Insufficient length for noisy message" 
      end
      bitmap = []
      usable_noisy_message_length.times { bitmap << false }
      srand(Time.now.to_i)
      positions_selected = 0
      while (positions_selected < message.length)
        position_taken = rand(usable_noisy_message_length)
        if bitmap[position_taken]
          next
        else
          bitmap[position_taken] = true
          positions_selected = positions_selected.next
        end
      end
    
      noisy_message = ""
      0.upto(bitmap_size-1) { |byte|
        c = 0
        0.upto(7) { |bit|
          c = c + (1<<bit) if bitmap[byte * 8 + bit]
        }
        noisy_message << c.chr
      }
      pos_in_message = 0
      0.upto(usable_noisy_message_length-1) { |pos|
        if bitmap[pos]
          meaningful_byte = message[pos_in_message]
          noisy_message << meaningful_byte
          pos_in_message = pos_in_message.next
        else
          noise_byte = rand(256).chr
          noisy_message << noise_byte
        end
      }
      remaining_bytes.times {
          noise_byte = rand(256).chr
          noisy_message << noise_byte
      }
      return(noisy_message)
    end
  
  
    def remove_noise
      noisy_message = self
      bitmap_size = noisy_message.length / 9
      actual_message_length =  bitmap_size * 8
    
      actual_message_start = bitmap_size
      actual_message_finish = bitmap_size + actual_message_length - 1
      actual_message = noisy_message[actual_message_start..actual_message_finish]
    
      bitmap = []
      0.upto(bitmap_size - 1) { |byte|
        c = noisy_message[byte]
        0.upto(7) { |bit|
          bitmap[byte * 8 + bit] = (c[bit] == 1)
        }
      }
      clear_message = ""
      0.upto(actual_message_length) { |pos|
        meaningful = bitmap[pos]
        if meaningful
          clear_message << actual_message[pos]
        end
      }
      return(clear_message)
    end
  
  end
end

class String
  include Crypt::Noise
end