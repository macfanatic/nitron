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
      to_a
    end
    
    def count
      self.resultType = NSCountResultType
      to_a[0]
    end

    def pluck(column)
      self.resultType = NSDictionaryResultType
      
      attribute_description = entity.attributesByName[column]
      raise ArgumentError, "#{column} not a valid column name" if attribute_description.nil?
      
      self.propertiesToFetch = [attribute_description]
      to_a.collect { |r| r[column] }
    end
    
    def distinct
      self.returnsDistinctResults = true
      self
    end

    def first
      setFetchLimit(1)

      to_a[0]
    end

    def inspect
      to_a
    end
    
    def limit(l)
      l = l.to_i
      raise ArgumentError, "limit '#{l}' cannot be less than zero. Use zero for no limit." if l < 0
      self.fetchLimit = l
      self
    end
    
    def offset(o)
      o = o.to_i
      raise ArgumentError, "offset '#{o}' cannot be less than zero." if o < 0
      self.fetchOffset = o
      self
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
