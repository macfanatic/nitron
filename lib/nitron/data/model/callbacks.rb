module Nitron
  module Data
    class Model < NSManagedObject
      module Callbacks
    
        def self.included(base)
          base.extend(ClassMethods)
        end
    
        module ClassMethods
      
          def before_save(*args, &proc)
            register_callback(:before_save, *args, &proc)
          end
          
          def after_save(*args, &proc)
            register_callback(:after_save, *args, &proc)
          end
          
          def before_create(*args, &proc)
            register_callback(:before_create, *args, &proc)            
          end
          
          def after_create(*args, &proc)
            register_callback(:after_create, *args, &proc)
          end
          
          def before_destroy(*args, &proc)
            register_callback(:before_destroy, *args, &proc)            
          end
          
          def after_destroy(*args, &proc)
            register_callback(:after_destroy, *args, &proc)
          end
          
          def after_initialize(*args, &proc)
            register_callback(:after_initialize, *args, &proc)
          end
          
        private
          
          def registered_callbacks
            @registered_callbacks ||= %w(before_save after_save before_create after_create before_destroy after_destroy after_initialize).inject({}) { |hash, key| hash[key.to_sym] = []; hash; }
          end
          
          def register_callback(callback_type, *args, &proc)
            
            callback_type = callback_type.to_sym
            raise ArgumentError, "'#{callback_type}' is not a valid callback type" unless registered_callbacks.keys.include?(callback_type)
            
            options = args.extract_options!
            options.delete(:method)
            
            if block_given?
              registered_callbacks[callback_type] << Callback.new(callback_type, options, &proc)
            else
              raise ArgumentError, "must provide a method signature symbol, or provide a block" if args.empty?
              args.each do |sym|
                registered_callbacks[callback_type] << Callback.new(callback_type, options.merge({method:sym.to_sym}))
              end
            end
          end
        
        end

      private
      
        def run_callbacks(type)
          klass = self.class
          if self.class.ancestors.index(self.class.superclass) == 2
            klass = self.class.ancestors[1]
          end
          callbacks = klass.send(:registered_callbacks)[type.to_sym]
          callbacks.each { |callback| callback.run_if_needed(self) }
          true
        end
    
      end
    end
  end
end