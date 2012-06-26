module Nitron
  module Data
    class Relation < NSFetchRequest
      module FinderMethods
      
        def all
          to_a
        end
      
        def count
          return to_a.count if fetchOffset > 0
          self.resultType = NSCountResultType
          to_a[0]
        end
      
        def except(query_part)
          case query_part.to_sym
           when :where
             self.predicate = nil
           when :order
             self.sortDescriptors = nil
           when :limit
             self.fetchLimit = 0
           else
             raise ArgumentError, "unsupport query part '#{query_part}'"
           end
           self
        end
      
        def first
          self.fetchLimit = 1
          to_a[0]
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
          descriptors << NSSortDescriptor.sortDescriptorWithKey(column.to_s, ascending:opts.fetch(:ascending, true))
          self.sortDescriptors = descriptors
          self
        end
      
        def pluck(column)
          self.resultType = NSDictionaryResultType

           attribute_description = entity.attributesByName[column]
           raise ArgumentError, "#{column} not a valid column name" if attribute_description.nil?

           self.propertiesToFetch = [attribute_description]
           to_a.collect { |r| r[column] }
        end
      
        def uniq
          self.returnsDistinctResults = true
          self
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
      
      end
    end
  end
end