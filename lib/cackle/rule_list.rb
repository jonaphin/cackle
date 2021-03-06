module Cackle
  class RuleList
    def initialize(selection_array)
      @selections = selection_array.sort.reverse
      reorder_splats
      compile_regexes
    end
  
    def to_a
      @selections
    end
  
    def test(path, subject)
      disposition = soft_test(path, subject)
      
      return false if disposition == :soft_fail 
      return disposition
    end
    
    def soft_test(path, subject)
      relevant = @selections.select{|s| path =~ s.selector}
      return false if relevant.empty?

      relevant.map do |sel|
        return false if sel.properties['deny'] && sel.properties['deny'].include?(subject)
        return true if sel.properties['allow'] && sel.properties['allow'].include?(subject)
      end
      
      return :soft_fail
    end
  
    private
    def compile_regexes
      @selections.each{|s|s.compile_regex}
    end
  
    def reorder_splats
      yes_splat = splats
      no_splat = @selections - yes_splat
      @selections = yes_splat.reverse + no_splat
    end
  
    def splats
      @selections.select{|s|s.selector =~ /\*$/}
    end
  end

  class Selection
    attr_accessor :selector
    attr_accessor :properties
  
    def initialize(sel, prop)
      self.selector = sel
      self.properties = prop
    end
  
    def inspect
      "<Selection #{selector} #{properties.inspect} >"
    end
  
    def <=>(other)
      self.selector.length <=> other.selector.length
    end
  
    def compile_regex
      self.selector = Regexp.new(Regexp.escape(self.selector).gsub('\\*','.*'))
    end
  end
end