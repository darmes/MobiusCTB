#===============================RGSS CHANGES===================================
#==============================================================================
# ** RPG::Enemy changes
#==============================================================================
module RPG
  class Enemy
    alias base_name name
    #--------------------------------------------------------------------------
    # * Get IDs bundled with their Ranks
    #--------------------------------------------------------------------------
    def id_with_rank(rank_array)
      size = rank_array.xsize - 1
      result = []
      for id in 1..size
        rank = rank_array[id]
        if yield(rank)
          result.push([id, rank])
        end
      end
      return result
    end
    #--------------------------------------------------------------------------
    # * Get Strong Elements
    #--------------------------------------------------------------------------
    def strong_elements
      strong_element_array = id_with_rank(element_ranks) { |rank| rank > 3 }
      strong_element_array.sort! do |a,b|
        b[1] <=> a[1] # Sort greater rank (6) to front of array (lower index)
      end
      return strong_element_array.map do |tuple|
        tuple[0] # return just the ID
      end
    end
    #--------------------------------------------------------------------------
    # * Get Weak Elements
    #--------------------------------------------------------------------------
    def weak_elements
      weak_element_array = id_with_rank(element_ranks) { |rank| rank < 3 }
      weak_element_array.sort! do |a,b|
        a[1] <=> b[1] # Sort lower rank (1) to front of array (lower index)
      end
      return weak_element_array.map do |tuple|
        tuple[0] # return just the ID
      end
    end
    #--------------------------------------------------------------------------
    # * Get Element Efficiency - Human readable string
    #     element_id : Element ID
    #--------------------------------------------------------------------------
    def element_efficiency(element_id)
      element_rank = element_ranks[element_id]
      return element_rank_decode(element_rank)
    end
    #--------------------------------------------------------------------------
    # * Element Rank Decode - converts integer to string based on customization
    #--------------------------------------------------------------------------
    def element_rank_decode(element_rank)
      case element_rank
      when 1 # Very Weak = 200%
        return Mobius::Beastiary::ELEMENT_WORD_200
      when 2 # Weak = 150%
        return Mobius::Beastiary::ELEMENT_WORD_150
      when 3 # Normal = 100%
        return Mobius::Beastiary::ELEMENT_WORD_100
      when 4 # Resistant = 50%
        return Mobius::Beastiary::ELEMENT_WORD_50
      when 5 # Immune = 0%
        return Mobius::Beastiary::ELEMENT_WORD_0
      when 6 # Absorb = -100%
        return Mobius::Beastiary::ELEMENT_WORD_M100
      end
    end
    #--------------------------------------------------------------------------
    # * Get Strong States
    #--------------------------------------------------------------------------
    def strong_states
      strong_state_array = id_with_rank(state_ranks) { |rank| rank > 3 }
      strong_state_array.sort do |a,b|
        aID = a[0]
        aRank = a[1]
        aRating = $data_states[aID].rating
        bID = b[0]
        bRank = b[1]
        bRating = $data_states[bID].rating
        # Sort greater rank (6) to front of array (lower index)
        # If ranks are equal, sort higher rating to front
        [bRank, bRating] <=> [aRank, aRating]
      end
      return strong_state_array.map do |tuple|
        tuple[0] # return just the ID
      end
    end
    #--------------------------------------------------------------------------
    # * Get Weak States
    #--------------------------------------------------------------------------
    def weak_states
      weak_state_array = id_with_rank(state_ranks) { |rank| rank < 3 }
      weak_state_array.sort! do |a,b|
        aID = a[0]
        aRank = a[1]
        aRating = $data_states[aID].rating
        bID = b[0]
        bRank = b[1]
        bRating = $data_states[bID].rating
        # Sort lower rank (1) to front of array (lower index)
        # If ranks are equal, sort higher rating to front
        [aRank, bRating] <=> [bRank, aRating]
      end
      return weak_state_array.map do |tuple|
        tuple[0] # return just the ID
      end
    end
    #-------------------------------------------------------------------------- 
    # * Get State Efficiency - Human readable string
    #     state_id : State ID
    #--------------------------------------------------------------------------
    def state_efficiency(state_id)
      state_rank = state_ranks[state_id]
      return state_rank_decode(state_rank)
    end
    #--------------------------------------------------------------------------
    # * State Rank Decode - converts integer to string based on customization
    #--------------------------------------------------------------------------
    def state_rank_decode(state_rank)
      case state_rank
      when 1 # Very Weak = 100%
        return Mobius::Beastiary::STATUS_WORD_100
      when 2 # Weak = 80%
        return Mobius::Beastiary::STATUS_WORD_80
      when 3 # Normal = 60%
        return Mobius::Beastiary::STATUS_WORD_60
      when 4 # Resistant = 40%
        return Mobius::Beastiary::STATUS_WORD_40
      when 5 # Very Resistant = 20%
        return Mobius::Beastiary::STATUS_WORD_20
      when 6 # Immune = 0%
        return Mobius::Beastiary::STATUS_WORD_0
      end
    end
  end
end
