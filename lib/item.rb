module Combat
  class Item
    ############################################################################
    # 1. BASIC ACCESSORS :
    ############################################################################
    attr_accessor :type, :uses


    ############################################################################
    # 2. INITIALIZATION :
    ############################################################################
    def initialize(type)
      @type   = type
      @uses   = ITEMS[type][:uses]
    end

    ITEMS.each_pair do |item_type,item|
      method_name = "new_#{item_type.to_s}".to_sym
      Combat::Item.define_singleton_method(method_name) { Combat::Item.new item_type }
    end


    ############################################################################
    # 2. OTHER ACCESSORS :
    ############################################################################
    def name()    ITEMS[@type][:name]     end
    def effects() ITEMS[@type][:effects]  end


    ############################################################################
    # 4. USAGE :
    ############################################################################
    def use() 
      unless depleted?
        @uses -= 1
        effects

      else
        []

      end
    end

    def depleted?() @uses <= 0  end
    alias used? depleted?
  end
end
