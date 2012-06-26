module Nitron
  module Data
    class Callback
      
      attr_reader :type, :method_or_proc
      
      def initialize(type, options={}, &proc)
        @type = type
        @options = options || {}
        @method_or_proc = options[:method] || proc
      end
      
      def run_if_needed(object)
        @object = object
        run if should_run?
      end
      
      def to_s
        "<Nitron::Data::Callback type=#{type}, method_or_proc=#{method_or_proc}"
      end
      
    private
      
      def should_run?
        
        should_run = true
        
        # Consider an :if option
        if @options.include?(:if)
          if_method_or_proc = @options[:if]
          if if_method_or_proc.is_a? Proc
            should_run = @object.instance_exec(&if_method_or_proc)
          else
            should_run = @object.send(if_method_or_proc) == true
          end
        end
        
        # Consider an :unless option
        if @options.include?(:unless)
          unless_method_or_proc = @options[:unless]
          if unless_method_or_proc.is_a? Proc
            should_run = !@object.instance_exec(&unless_method_or_proc)
          else
            should_run = @object.send(unless_method_or_proc) == false
          end
        end
        
        should_run
        
      end
      
      def run
        case method_or_proc
        when String, Symbol
          @object.send(method_or_proc)
        when Proc
          @object.instance_exec(&method_or_proc)
        end
      end
      
    end
  end
end