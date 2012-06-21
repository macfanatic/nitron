module Nitron
  class Model < NSManagedObject
    class << self
      def all
        Data::Relation.alloc.initWithClass(self)
      end
      
      def count
        all.count
      end
      
      def pluck(column)
        all.pluck(column)
      end
      
      def distinct
        all.distinct
      end

      def create(attributes={})
        model = new(attributes)
        model.save

        model
      end
      
      def create!(attributes={})
        model = new(attributes)
        model.save!
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
      
      def limit(l)
        relation.limit(l)
      end
      
      def offset(o)
        relation.offset(o)
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
    
    def new_record?
      managedObjectContext.nil?
    end
    
    def valid?
      err = Pointer.new(:object)
      v = new_record? ? validateForInsert(err) : validateForUpdate(err)
      yield(v, err[0]) if block_given?
      v
    end
    
    def errors
      errors = {}
      valid? do |valid, error|
        next if error.nil?
        if error.code == NSValidationMultipleErrorsError
          errs = error.userInfo[NSDetailedErrorsKey]
          errs.each do |nserr|
            property = nserr.userInfo['NSValidationErrorKey']
            errors[property] = message_for_error_code(nserr.code, property)
          end
        else
          property = error.userInfo['NSValidationErrorKey']
          errors[property] = message_for_error_code(error.code, property)
        end
      end
      errors
    end

    def inspect
      properties = entity.properties.map { |property| "#{property.name}: #{valueForKey(property.name).inspect}" }

      "#<#{entity.name} #{properties.join(", ")}>"
    end

    def save!
      unless context = managedObjectContext
        context = UIApplication.sharedApplication.delegate.managedObjectContext
        context.insertObject(self)
      end

      error = Pointer.new(:object)
      unless context.save(error)
        managedObjectContext.deleteObject(self)
        raise Nitron::RecordInvalid, self and return false
      end
      true
    end
    
    def save
      begin
        save!
      rescue Nitron::RecordInvalid => e
        return false
      end
      true
    end
    
  private
    def message_for_error_code(c, prop)
      message = case c
        when NSValidationMissingMandatoryPropertyError
          "can't be blank"
        when NSValidationNumberTooLargeError
          "too large"
        when NSValidationNumberTooSmallError
          "too small"
        when NSValidationDateTooLateError
          "too late"
        when NSValidationDateTooSoonError
          "too soon"
        when NSValidationInvalidDateError
          "invalid date"
        when NSValidationStringTooLongError
          "too long"
        when NSValidationStringTooShortError
          "too short"
        when NSValidationStringPatternMatchingError
          "incorrect pattern"
        when NSValidationRelationshipExceedsMaximumCountError
          "too many"
        when NSValidationRelationshipLacksMinimumCountError
          "too few"
        when NSValidationRelationshipDeniedDeleteError
          "can't delete"
        when NSManagedObjectValidationError
          warnings = entity.propertiesByName[prop].validationWarnings rescue []
          warnings.empty? ? "invalid" : warnings.join(', ')
        end
    end
    
  end
end
