module Nitron
module Data
  class Relation < NSFetchRequest
    def initWithClass(entityClass)
      if init
        setEntity(entityClass.entityDescription)
      end

      self
    end

    def all
      self
    end

    def first
      setFetchLimit(1)

      to_a[0]
    end
    
    def includes(*relatives)
      
      raise ArgumentError, "Must provide at least one relationship to prefetch." if relatives.empty?
      
      relatives = relatives.collect(&:to_s)
      supported_relationship_names = entity.relationshipsByName.keys
      unsupported_keys = relatives - supported_relationship_names
      
      raise ArgumentError, "Following relationships are not defined for '#{entity.name}': #{unsupported_keys.join(', ')}" unless unsupported_keys.empty?
      self.relationshipKeyPathsForPrefetching = relatives
      self
    end

    def inspect
      to_a
    end

    def order(column, opts={})
      descriptors = sortDescriptors || []

      descriptors << NSSortDescriptor.alloc.initWithKey(column.to_s, ascending:opts.fetch(:ascending, true))
      setSortDescriptors(descriptors)

      self
    end

    def to_a
      error = Pointer.new(:object)
      context.executeFetchRequest(self, error:error)
    end

    def where(format, *args)
      predicate = NSPredicate.predicateWithFormat(format.gsub("?", "%@"), argumentArray:args)

      if self.predicate
        self.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([predicate])
      else
        self.predicate = predicate
      end

      self
    end

  private

    def context
      UIApplication.sharedApplication.delegate.managedObjectContext
    end
  end
end
end
