class Restfulie::Common::Builder::Marshalling::Xml < Restfulie::Common::Builder::Marshalling::Base
  include ActionController::UrlWriter
  include Restfulie::Common::Builder::Helpers
  include Restfulie::Common::Error
  
  ATOM_ATTRIBUTES = [
  ]
  
  ATOM_ATTRIBUTES_ENTRY = ATOM_ATTRIBUTES + [
  ]
  
  ATOM_ATTRIBUTES_FEED = ATOM_ATTRIBUTES + [
  ]
  
  ATTRIBUTES_ALREADY_IN_ATOM_SPEC = [
    "id", "created_at", "updated_at", "title"
  ]

  def initialize(object, rules)
    @object = object
    @rules   = rules
  end

  def builder_collection(options = {})
    builder_feed(@object, @rules, options).to_xml
  end

  def builder_member(options = {})
    debugger
    builder_entry(@object, @rules, options).to_xml
  end

private

  def builder_feed(objects, rules_blocks, options = {})
    rule = Restfulie::Common::Builder::CollectionRule.new(rules_blocks)

    rule.blocks.unshift(default_collection_rule) if options[:default_rule]
    rule.metaclass.send(:attr_accessor, *ATOM_ATTRIBUTES_FEED)
    rule.apply(objects, options)

    debugger
    serializer = Object.new
    serializer
    # def serializer.method_missing(sym, *args, &block)
    #   puts "setting #{sym.to_s} to #{args}"
    # end
    # def serializer.to_xml(options = {})
    #   super(options)
    # end
    # serializer
    # atom = ::Atom::Feed.new do |feed|
    #   # Set values
    #   (ATOM_ATTRIBUTES_FEED - [:links]).each do |field|
    #     feed.send("#{field}=".to_sym, rule.send(field)) unless rule.send(field).nil?
    #   end
    # 
    #   # Namespaces
    #   builder_namespaces(rule.namespaces, feed)
    # 
    #   # Transitions
    #   rule.links.each do |link|
    #     atom_link = {:rel => link.rel, :href => link.href, :type => (link.type || 'application/atom+xml')}
    #     feed.links << ::Atom::Link.new(atom_link) unless atom_link[:href].nil?
    #   end
    # 
    #   # Entries
    #   options.delete(:values)
    #   member_options = options.merge(rule.members_options || {})
    #   objects.each do |member|
    #     feed.entries << builder_entry(member, rule.members_blocks || [], member_options)
    #   end
    # end
  end
  
  # TODO: Validate of the required fields
  def default_collection_rule
    Proc.new do |collection_rule, objects, options|
      # Passed values
      (options[:values] || {}).each { |key, value| collection_rule.send("#{key}=".to_sym, value)}
      
      # Default values
      collection_rule.id        ||= options[:self]
      collection_rule.title     ||= "#{objects.first.class.to_s.pluralize.demodulize} feed"
      collection_rule.updated   ||= updated_collection(objects)

      # Transitions
      collection_rule.links << link(:rel => :self, :href => options[:self]) unless options[:self].nil?
    end
  end

  # def builder_entry(object, rules_blocks, options = {})
  #   rule    = Restfulie::Common::Builder::MemberRule.new(rules_blocks)
  #   options = namespace_enhance(options)
  #   
  #   rule.blocks.unshift(default_member_rule) if options[:default_rule]
  #   rule.metaclass.send(:attr_accessor, *ATOM_ATTRIBUTES_ENTRY)
  #   rule.apply(object, options)
  # 
  #   atom = ::Atom::Entry.new do |entry|
  #     # Set values
  #     (ATOM_ATTRIBUTES_ENTRY - [:links]).each do |field|
  #       entry.send("#{field}=".to_sym, rule.send(field)) unless rule.send(field).nil?
  #     end
  # 
  #     # Namespaces
  #     builder_namespaces(rule.namespaces, entry)
  #     
  #     # Transitions
  #     rule.links.each do |link|
  #       atom_link = {:rel => link.rel, :href => link.href, :type => link.type}
  # 
  #       # Self
  #       if link.href.nil?
  #         if link.rel == "self"
  #           path = object
  #         else
  #           association = object.class.reflect_on_all_associations.find { |a| a.name.to_s == link.rel }
  #           path = (association.macro == :has_many) ? [object, association.name] : object.send(association.name) unless association.nil? 
  #         end
  #         atom_link[:href] = polymorphic_url(path, :host => host) rescue nil
  #         atom_link[:type] = link.type || 'application/atom+xml'
  #       end
  # 
  #       entry.links << ::Atom::Link.new(atom_link) unless atom_link[:href].nil?
  #     end
  #   end
  # end
  # 
  # def default_member_rule
  #   Proc.new do |member_rule, object, options|
  #     # Passed values
  #     (options[:values] || {}).each { |key, value| set_attribute(member_rule, key, value) }
  # 
  #     # Default values
  #     member_rule.id      ||= polymorphic_url(object, :host => host) rescue nil
  #     member_rule.title   ||= object.respond_to?(:title) && !object.title.nil? ? object.title : "Entry about #{object.class.to_s.demodulize}"
  #     member_rule.updated ||= object.updated_at if object.respond_to?(:updated_at)
  # 
  #     # Namespace
  #     unless options[:namespace].nil?
  #       member_rule.namespace(object, options[:namespace][:uri], options[:namespace])
  #     end
  #   end
  # end
  # 
  # def updated_collection(objects)
  #   objects.map { |item| item.updated_at if item.respond_to?(:updated_at) }.compact.max || Time.now
  # end
  # 
  # def builder_namespaces(namespaces, atom)
  #   kclass = atom.class
  #   namespaces.each do |ns|
  #     register_namespace(ns.namespace, ns.uri, kclass)
  #     ns.each do |key, value|
  #       unless ATTRIBUTES_ALREADY_IN_ATOM_SPEC.include?(key.to_s)
  #         register_element(ns.namespace, key, kclass)
  #         atom.send("#{ns.namespace}_#{key}=".to_sym, value)
  #       end
  #     end
  #   end
  # end
  # 
  # def host
  #   # TODO: If we split restfulie into 2 separate gems, we may need not to use Restfulie::Server
  #   #       inside Restfulie::Common
  #   Restfulie::Server::Configuration.host
  # end
  # 
  # def register_namespace(namespace, uri, klass)
  #   klass.add_extension_namespace(namespace, uri) unless klass.known_namespaces.include? uri
  # end
  # 
  # def register_element(namespace, attribute, klass)
  #   attribute = "#{namespace}:#{attribute}"
  #   klass.element(attribute) if element_unregistered?(attribute, klass)
  # end
  # 
  # def element_unregistered?(element, klass)
  #   klass.element_specs.select { |k,v|  v.name == element }.empty?
  # end
  # 
  # # TODO : Move error handling to class rule, maybe?
  # def set_attribute(rule, attribute, value)
  #   begin
  #     rule.send("#{attribute}=".to_sym, value)
  #   rescue NoMethodError
  #     raise AtomMarshallingError.new("Attribute #{attribute} unsupported in Atom #{rule_type_name(rule)}.")
  #   end
  # end
  # 
  # def rule_type_name(rule)
  #   rule.kind_of?(Restfulie::Common::Builder::MemberRule) ? 'Entry' : 'Feed'
  # end
  # 
  # def namespace_enhance(options)
  #   if !options[:namespace].nil? && options[:namespace].kind_of?(String)
  #     options[:namespace] = { :uri => options[:namespace], :eager_load => true }
  #   end
  #   options
  # end
end


module Restfulie::Server::ActionView::TemplateHandlers
  
  class Tokamak < ActionView::TemplateHandler
    # include ActionView::TemplateHandlers::Compilable
      
    # TODO: Implement error for code not return builder
    # def compile(template)
    #   "extend Restfulie::Common::Builder::Helpers; " +
    #   "extend Restfulie::Server::ActionView::Helpers; " +
    #   "code_block = lambda { #{template.source} };" + 
    #   "builder = code_block.call; " +
    #   "builder.to_xml "
    # end
  end
end



class Room
  attr_reader :x, :y, :rooms
  def initialize(position, del, value)
    @x = del[0]
    @y = del[1]
    @position = position
    @value = value
    @rooms = []
  end
  
  def name
    exit? ? "exit" : "#{x},#{y}"
  end
  
  def <<(room)
    @rooms << room
  end
  
  def exit?
    @value=='X'
  end
  
  def position
    exit? ? 'exit' : @position
  end
end

class Maze
  
  def map
      [ 
      "S****",
      "-****",
      "-****",
      "----X"
      ]
  end
  
  def start_point
    [0,0]
  end
  def end_point
    [4,3]
  end
  def contains(x,y)
    x>=0 && y>=0 && y<map.length && x<map[y].length
  end
  
  def room(x,y)
    raise Error "You are out of the maze" unless contains(x,y)
    raise Error "There is a wall at #{x}, #{y}" unless possible_place(x,y)
    
    room = Room.new('', [x,y], map[y][x..x])
    {'north' => [0, -1], 'south' => [0, 1], 'east' => [1, 0], 'west' => [-1, 0]}.each do |position, v|
      nx = x + v[0]
      ny = y + v[1]
      room << Room.new(position, [nx, ny], map[ny][nx..nx]) if possible_place(nx, ny)
    end
    room
  end
  def possible_place(x,y)
    contains(x,y) && map[y][x..x]!='*'
  end
  
end

class MazesController < ApplicationController
  
  include Restfulie::Server::ActionController::Base

  respond_to :maze, :xml
  
  def entry
    @maze = Maze.new
    redirect_to maze_position_url(@maze.start_point[0], @maze.start_point[1])
  end
  
  def position
    @maze = Maze.new
    y = params[:y].to_i
    x = params[:x].to_i
    respond_with @room = @maze.room(x,y)
  end
  
end
