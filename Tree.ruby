# frozen_string_literal: true

load './Node.ruby'
require 'byebug'
class Tree
  attr_accessor :root

  def initialize(array)
    @array = array
    @array.sort!.uniq!
    @root = build_tree(@array)
  end

  def build_tree(array)
    return if array.length.zero?

    mid = array.length / 2
    node = Node.new(array[mid])
    node.left = build_tree(array[0...mid])
    node.right = build_tree(array[1 + mid..-1])
    node
  end

  def insert(val, target = @root)
    return if target.main == val
    if target.left.nil? && target.main >= val
      return target.left = Node.new(val)
    elsif target.right.nil? && target.main <= val
      return target.right = Node.new(val)
    end

    insert(val, target.left) if val < target.main
    insert(val, target.right) if val > target.main
  end

  def helper(val)
    if val.left.nil?
      val_dup = val.dup
      delete(val.main)
      return val_dup
    end

    helper(val.left)
  end

  def delete(val, _target = @root)
    val_node = find(val)
    val_root = find_root(val)
    return if val_root.nil?

    if val_node.right.nil? && val_node.left.nil?
      if val_root.main < val_node.main
        val_root.right = nil
      else
        val_root.left = nil
      end
    elsif !val_node.right.nil? && !val_node.left.nil?
      nearest_largest = helper(val_node.right)
      val_node.main = nearest_largest.main
    elsif !val_node.right.nil?
      if val_node.main > val_root.main
        val_root.right = nil
        val_root.right = val_node.right
      else
        val_root.left = nil
        val_root.left = val_node.right
      end
    elsif !val_node.left.nil?
      if val_node.main > val_root.main
        val_root.right = nil
        val_root.right = val_node.left
      else
        val_root.left = nil
        val_root.left = val_node.left
      end
    elsif val_node.main > val_root.main
      val_root.right = nil
      val_root.right = val_node.left
    elsif val_node.main < val_root.main
      val_root.left = nil
      val_root.left = val_node.right
    end
  end

  def find(val, target = @root)
    return target if val == target.main

    if val >= target.main && !target.right.nil?
      find(val, target.right)
    elsif val <= target.main && !target.left.nil?
      find(val, target.left)
    end
  end

  def find_root(val, target = @root)
    return nil if target.main == val

    return target if target.left.main == val || target.right.main == val

    if val >= target.main && !target.right.nil?
      find_root(val, target.right)
    elsif val <= target.main && !target.left.nil?
      find_root(val, target.left)
    end
  end

  def level_order(root = @root)
    queue_array = []

    queue_array.unshift(root)

    return_array = []

    i = 0

    while i < queue_array.length
      left = queue_array[i].left unless queue_array[i].left.nil?
      right = queue_array[i].right unless queue_array[i].right.nil?

      if block_given?
        yield(left)
        yield(right)
      end

      queue_array.push(left) unless queue_array[i].left.nil?
      queue_array.push(right) unless queue_array[i].right.nil?
      return_array.push(queue_array[i].main)

      queue_array.shift

    end

    return_array
  end

  def preorder(root = @root, array = [], &block)
    yield(root) if block_given?
    array.push(root.main)
    preorder(root.left, array, &block) unless root.left.nil?
    preorder(root.right, array, &block) unless root.right.nil?
    array
  end

  def inorder(root = @root, array = [])
    inorder(root.left, array) unless root.left.nil?
    yield(root.main) if block_given?
    array.push(root.main)
    inorder(root.right, array) unless root.right.nil?
    array
  end

  def postorder(root = @root, array = [])
    postorder(root.left, array) unless root.left.nil?
    postorder(root.right, array) unless root.right.nil?
    yield(root) if block_given?
    array.push(root.main)
    array
  end

  def depth(node, counter = 0, target = @root)
    return counter if node == target

    if node.main >= target.main && !target.right.nil?
      counter += 1
      depth(node, counter, target.right)
    elsif node.main <= target.main && !target.left.nil?
      counter += 1
      depth(node, counter, target.left)
    end
  end

  def height(node, counter_left = 0, counter_right = 0)
    if node.left.nil? && node.right.nil?
      array = [counter_left, counter_right]
      return array.max
    end

    if !node.left.nil? && node.right.nil?
      counter_left += 1
      height(node.left, counter_left, counter_right)
    elsif !node.right.nil? && node.left.nil?
      counter_right += 1
      height(node.right, counter_left, counter_right)
    end
  end

  def balanced?(root = @root)
    height_left = height(root.left) unless root.left.nil?

    height_right = height(root.right) unless root.right.nil?

    if !height_left.nil? && !height_right.nil? && (height_left - height_right > 1 || height_right - height_left > 1)
      return false
    end

    balanced?(root.left) unless root.left.nil?
    balanced?(root.right) unless root.right.nil?
  end

  def rebalance
    unless balanced?
      array = inorder
      array.sort!.uniq!
      return @root = build_tree(array)
    end
    p 'Tree is already balanced'
    false
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.main}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end

def driver
  array = Array.new(15) { rand(1..100) }
  tree = Tree.new(array)
  p tree.balanced?
  p tree.preorder
  p tree.inorder
  p tree.postorder
  array_insert = Array.new(15) { rand(1..1000) }
  array_insert.each do |ele|
    tree.insert(ele)
  end
  p tree.balanced?
  tree.rebalance
  p tree.balanced?
  p tree.pretty_print
  p tree.balanced?
  p tree.preorder
  p tree.inorder
  p tree.postorder
end

driver
