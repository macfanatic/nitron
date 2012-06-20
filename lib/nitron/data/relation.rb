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
    
    def count
      self.resultType = NSCountResultType
      to_a[0]
    end

    def first
      setFetchLimit(1)

      to_a[0]
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
