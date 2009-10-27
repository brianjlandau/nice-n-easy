require 'sinatra/base'
unless Object.method_defined?(:blank?)
  require 'nice-n-easy/blank'
end

module Sinatra
  module NiceEasyHelpers
    BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked).to_set
    BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map(&:to_sym))
    
    def link(content, href, options={})
      tag :a, content, options.merge(:href => href)
    end
    
    def label(*args)
      obj, field, options = extract_options_and_field(*args)
      display = options.delete(:label)
      if display.blank?
        if String.method_defined?(:titleize)
          display = field.blank? ? obj.to_s.titleize : field.to_s.titleize
        else
          display = field.blank? ? obj.to_s : field.to_s
        end
      end
      tag :label, display, options.merge(:for => (field.blank? ? obj : "#{obj}_#{field}"))
    end
    
    def text_field(*args)
      input_tag 'text', *args
    end
    
    def password_field(*args)
      input_tag 'password', *args
    end
    
    def file_field(*args)
      input_tag 'file', *args
    end
    
    def button(*args)
      options = args.extract_options!
      name = args.shift
      content = args.shift
      type = args.shift || 'submit'
      tag :button, content, options.merge(:type => type, :name => name, :id => name)
    end
    
    def text_area(*args)
      obj, field, options = extract_options_and_field(*args)
      value = get_value(obj, field)
      tag :textarea, value, options.merge(get_id_and_name(obj, field))
    end
    
    def image_input(src, options={})
      single_tag :input, options.merge(:type => 'image', :src => File.join('/public/images', src))
    end
    
    def submit(value = "Save", options={})
      single_tag :input, options.merge(:type => "submit", :value => value)
    end
    
    def checkbox(*args)
      input_tag 'checkbox', *args
    end
    
    def radio(*args)
      input_tag 'radio', *args
    end
    
    def select_field(*args)
      case args.size
      when 2
        options = {}
        items = args.pop
        obj = args.shift
        field = nil
      else
        options = args.extract_options!
        items = args.pop
        obj = args.shift
        field = args.shift
      end
      
      unless items.is_a? Enumerable
        raise ArgumentError, 'the items parameter must be an Enumerable object'
      end
      
      value = get_value(obj, field)
      
      content = items.inject([]) { |opts, option|
        text, opt_val = option_text_and_value(option)
        opts << tag(:option, text, {:value => opt_val, :selected => (opt_val == value)})
      }.join("\n")
      
      tag :select, content, options.merge(get_id_and_name(obj, field))
    end
    
    def hidden_field(*args)
      input_tag 'hidden', *args
    end
    
    # standard open and close tags
    # EX : tag :h1, "shizam", :title => "shizam"
    # => <h1 title="shizam">shizam</h1>
    def tag(name,content,options={})
      "<#{name.to_s}#{tag_options(options)}>#{content}</#{name.to_s}>"
    end
    
    # standard single closing tags
    # single_tag :img, :src => "images/google.jpg"
    # => <img src="images/google.jpg" />
    def single_tag(name,options={})
      "<#{name.to_s}#{tag_options(options)} />"
    end
    
    private
    
    def input_tag(type, *args)
      obj, field, options = extract_options_and_field(*args)
      value = get_value(obj, field)
      case type.to_sym
      when :radio
        if options[:value].nil? || options[:value] =~ /^\s*$/
          raise ArgumentError, 'for radio inputs a value options must be provided'
        end
        options[:checked] = true if value == options[:value]
      when :checkbox
        if options[:value].nil? || options[:value] =~ /^\s*$/
          raise ArgumentError, 'for checkbox inputs a value options must be provided'
        end
        options[:checked] = "checked" if (value == options[:value] || (value.is_a?(Enumerable) && value.include?(options[:value])))
      else
        options[:value] = value
      end
      single_tag :input, options.merge(:type => type).merge(get_id_and_name(obj, field))
    end
    
    def get_value(obj, field)
      if field.blank?
        @params[obj]
      else
        case obj
        when String, Symbol
          begin
            @params[obj][field]
          rescue NoMethodError
            nil
          end
        else
          obj.send(field.to_sym)
        end
      end
    end
    
    def get_id_and_name(obj, field)
      if field.blank?
        {:id => obj.to_s, :name => obj.to_s}
      else
        case obj
        when String, Symbol
          {:id => "#{obj}_#{field}", :name => "#{obj}[#{field}]"}
        else
          obj_name = obj.class.name.demodulize.underscore
          {:id => "#{obj_name}_#{field}", :name => "#{obj_name}[#{field}]"}
        end
      end
    end
    
    def option_text_and_value(option)
      # Options are [text, value] pairs or strings used for both.
      if !option.is_a?(String) and option.respond_to?(:first) and option.respond_to?(:last)
        [option.first, option.last]
      else
        [option, option]
      end
    end
    
    def tag_options(options)
      unless options.blank?
        attrs = []
        options.each_pair do |key, value|
          if BOOLEAN_ATTRIBUTES.include?(key)
            attrs << %(#{key}="#{key}") if value
          else
            attrs << %(#{key}="#{value}") if !value.nil?
          end
        end
        " #{attrs.sort * ' '}" unless attrs.empty?
      end
    end
    
    def extract_options_and_field(*args)
      options = args.extract_options!
      obj = args.shift
      field = args.shift
      [obj, field, options]
    end
    
  end
  
  helpers NiceEasyHelpers
end

unless Hash.method_defined?(:extract_options!)
  class Hash
    def extract_options!
      last.is_a?(::Hash) ? pop : {}
    end
  end
end
