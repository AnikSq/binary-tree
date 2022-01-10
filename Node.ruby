# frozen_string_literal: true

class Node
    include Comparable
  
    attr_accessor :main, :left, :right
  
    def initialize(main)
      @main = main
      @left = nil
      @right = nil
    end
  end
  