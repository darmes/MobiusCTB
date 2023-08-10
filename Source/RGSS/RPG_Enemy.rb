#===============================RGSS CHANGES===================================
#==============================================================================
# ** RPG::Enemy changes
#==============================================================================
module RPG
  class Enemy
    alias base_name name
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
