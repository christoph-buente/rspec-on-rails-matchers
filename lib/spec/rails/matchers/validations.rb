module Spec
  module Rails
    module Matchers
      def validate_presence_of(attribute)
        return simple_matcher("model to validate the presence of #{attribute}") do |model|
          model.send("#{attribute}=", nil)
          !model.valid? && model.errors.invalid?(attribute)
        end
      end

      def validate_length_of(attribute, options)
        if options.has_key? :within
          min = options[:within].first
          max = options[:within].last
        elsif options.has_key? :is
          min = options[:is]
          max = min
        elsif options.has_key? :minimum
          min = options[:minimum]
        elsif options.has_key? :maximum
          max = options[:maximum]
        end
        
        return simple_matcher("model to validate the length of #{attribute} within #{min || 0} and #{max || 'Infinity'}") do |model|
          invalid = false
          if !min.nil? && min >= 1
            model.send("#{attribute}=", 'a' * (min - 1))

            invalid = !model.valid? && model.errors.invalid?(attribute)
          end
          
          if !max.nil?
            model.send("#{attribute}=", 'a' * (max + 1))

            invalid ||= !model.valid? && model.errors.invalid?(attribute)
          end
          invalid
        end
      end
      
      def validate_numericality_of(attribute, options = {})
        
        blank = max = min = odd = even = nil
        
        if options.blank?
          blank = true                  
        elsif options.has_key? :greater_than          
          min = (options[:greater_than] + 1)
        elsif options.has_key? :greater_than_or_equal_to
          min = options[:greater_than_or_equal_to]
        elsif options.has_key? :equal_to
          min = options[:equal_to] 
          max = options[:equal_to]
        elsif options.has_key? :less_than
          max = (options[:less_than] - 1)
        elsif options.has_key? :less_than_or_equal_to
          max = options[:less_than_or_equal_to]
        end

        if options.has_key? :odd
          odd = true
        elsif options.has_key? :even
          even = true
        end
        
        return simple_matcher("model to validate #{attribute} to be a number between #{min || 0} and #{max || 'Infinity'} inclusive") do |model|
          invalid = true
          if !min.nil?
            model.send("#{attribute}=", (min - 1))
            invalid &&= !model.valid? && model.errors.invalid?(attribute)
          end
          
          if !max.nil?
            model.send("#{attribute}=", (max + 1))
            invalid &&= !model.valid? && model.errors.invalid?(attribute)
          end
          
          if !odd.nil?
            value = [(min || 0), (max || 2)].min
            value += 1 if value.odd?
            model.send("#{attribute}=", (value))
            invalid &&= !model.valid? && model.errors.invalid?(attribute)
          end

          if !even.nil?
            value = [(min || 0), (max || 2)].min
            value += 1 if value.even?
            model.send("#{attribute}=", (value))
            invalid &&= !model.valid? && model.errors.invalid?(attribute)
          end
          
          if !blank.nil?
            model.send("#{attribute}=", ('character'))
            invalid &&= !model.valid? && model.errors.invalid?(attribute)
          end
          invalid
        end
      end

      def validate_uniqueness_of(attribute)
        return simple_matcher("model to validate the uniqueness of #{attribute}") do |model|
          model.class.stub!(:find).and_return(true)
          !model.valid? && model.errors.invalid?(attribute)
        end
      end

      def validate_confirmation_of(attribute)
        return simple_matcher("model to validate the confirmation of #{attribute}") do |model|
          model.send("#{attribute}_confirmation=", 'asdf')
          !model.valid? && model.errors.invalid?(attribute)
        end
      end
    end
  end
end