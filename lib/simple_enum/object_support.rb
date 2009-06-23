module SimpleEnum
  module ObjectSupport
    
    # Convert object to symbol for use in symbolized enum
    # methods. Return value is supposed to be a symbol,
    # though strings should work as well.
    #
    # The default behaviour is to try +to_sym+ first, then
    # checks if a field named +name+ exists or finally falls
    # back to +to_param+ method as provided by ActiveSupport.
    #
    # It's perfectly for subclasses to override this method,
    # to provide custom +to_enum_sym+ behaviour, e.g. if
    # the symbolized value is in e.g. +title+:
    #
    #    class FormOfAddress < ActiveRecord::Base
    #      attr_accessor :title
    #      def to_enum_sym; title; end
    #    end
    #
    # *Note*: to provide better looking methods values for +name+
    # are <tt>parametereize('_')</tt>'d, so it might be a good idea to do
    # the same thing in a custom +to_enum_sym+ method, like (for the
    # example above):
    #
    #    def to_enum_sym; title.parameterize('_').to_sym; end
    #
    # *TODO*: The current implementation does not handle nil values very
    # gracefully, so if +name+ returns +nil+, it should be handled
    # a bit better I suppose...
    def to_enum_sym
      return to_sym if respond_to?(:to_sym)
      return name.to_s.parameterize('_').to_sym if respond_to?(:name)
      to_param.to_sym unless blank? # fallback, unless empty...
    end
  end
end