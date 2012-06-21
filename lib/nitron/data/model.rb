module Nitron
  class Model < NSManagedObject
    class << self
      def all
        Data::Relation.alloc.initWithClass(self)
      end

      def create(attributes={})
        model = new(attributes)
        model.save

        model
      end

      def destroy(object)
        if context = object.managedObjectContext
          context.deleteObject(object)

          error = Pointer.new(:object)
          context.save(error)
        end
      end

      def entityDescription
        @_metadata ||= UIApplication.sharedApplication.delegate.managedObjectModel.entitiesByName[name]
      end

      def find(object_id)
        unless entity = find_by_id(object_id)
          raise "No record found!"
        end

        entity
      end

      def first
        relation.first
      end

      def method_missing(method, *args, &block)
        if method.start_with?("find_by_")
          attribute = method.gsub("find_by_", "")
          relation.where("#{attribute} = ?", *args).first
        else
          super
        end
      end

      # Provide a :context option (true|false|NSManagedObjectContext instance) to assign to a context upon insertion, or false to insert into default context during save
      def new(attributes={})
        
        # Determine if you're wanting to assign to the default context, a provided context, or no context (default)
        context = nil
        assign_to_context = attributes.delete(:context) || false
        if [TrueClass, FalseClass].include?(assign_to_context.class)
          if assign_to_context
            context = UIApplication.sharedApplication.delegate.managedObjectContext
          end
        elsif assign_to_context.is_a?(NSManagedObjectContext)
          context = assign_to_context
        end
        
        self.alloc.initWithEntity(entityDescription, insertIntoManagedObjectContext:context).tap do |model|
          attributes.each do |keyPath, value|
            model.setValue(value, forKey:keyPath)
          end
        end
      end

      def respond_to?(method)
        if method.start_with?("find_by_")
          true
        else
          super
        end
      end

      def order(*args)
        relation.order(*args)
      end

      def where(*args)
        relation.where(*args)
      end

    private

      def relation
        Data::Relation.alloc.initWithClass(self)
      end
    end

    def destroy
      self.class.destroy(self)
    end

    def inspect
      properties = entity.properties.map { |property| "#{property.name}: #{valueForKey(property.name).inspect}" }

      "#<#{entity.name} #{properties.join(", ")}>"
    end

    def save
      unless context = managedObjectContext
        context = UIApplication.sharedApplication.delegate.managedObjectContext
        context.insertObject(self)
      end

      error = Pointer.new(:object)
      context.save(error)
    end
  end
end
