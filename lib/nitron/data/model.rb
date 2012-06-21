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
      
      def except(query_part)
        relation.except(query_part)
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

      def new(attributes={})
        self.alloc.initWithEntity(entityDescription, insertIntoManagedObjectContext:nil).tap do |model|
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
