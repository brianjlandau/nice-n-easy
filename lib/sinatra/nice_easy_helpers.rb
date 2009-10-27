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
    
    def image_tag(src, options = {})
      single_tag :img, options.merge(:src => compute_public_path(src, 'images'))
    end
    
    def javascript_include_tag(*sources)
      sources.inject([]) { |tags, source|
        tags << tag(:script, '', {:src => compute_public_path(source, 'javascripts', 'js'), :type => 'text/javascript'})
        tags
      }.join("\n")
    end
    
    def stylesheet_link_tag(*sources)
      options = sources.extract_options!.symbolize_keys
      sources.inject([]) { |tags, source|
        tags << single_tag(:link, {:href => compute_public_path(source, 'stylesheets', 'css'),
                                   :type => 'text/css', :rel => 'stylesheet', :media => 'screen'}.merge(options))
        tags
      }.join("\n")
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
      options = args.extract_options!.symbolize_keys
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
      single_tag :input, options.merge(:type => 'image', :src => compute_public_path(src, 'images'))
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
        options = args.extract_options!.symbolize_keys
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
      options = args.extract_options!.symbolize_keys
      obj = args.shift
      field = args.shift
      [obj, field, options]
    end
    
    def compute_public_path(source, dir, ext = nil)
      source_ext = File.extname(source)[1..-1]
      if ext && source_ext.blank?
        source += ".#{ext}"
      end

      unless source =~ %r{^[-a-z]+://}
        source = "/#{dir}/#{source}" unless source[0] == ?/
      end

      return source
    end
    
  end
  
  helpers NiceEasyHelpers
end

unless Array.method_defined?(:extract_options!)
  class Array
    def extract_options!
      last.is_a?(::Hash) ? pop : {}
    end
  end
end
unless Hash.method_defined?(:symbolize_keys)
  class Hash
    def symbolize_keys
      inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
  end
end
