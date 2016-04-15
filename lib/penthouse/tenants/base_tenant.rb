#
# This class provides an abstract for the tenant interface. Whilst any Proc
# could be used, it's safest for people to sub-class to ensure that any future
# interface changes are catered for.
#
# A tenant class's responsibility is to receive a block, around which it should
# handle switching to the given tenant's configuration, ensuring that if an
# exception occurs, the configuration is reset back to the global configuration.
#
module Penthouse
  module Tenants
    class BaseTenant
      attr_accessor :identifier
      private :identifier=

      # @param identifier [String, Symbol] An identifier for the tenant
      def initialize(identifier:, **args)
        self.identifier = identifier
      end

      # @abstract placeholder for the relevant tenant-switching code
      # @param block [Block] The code to execute within the tenant
      # @yield [BaseTenant] The current tenant instance
      # @return [void]
      def call(&block)
        raise NotImplementedError
      end

      # @abstract creates the tenant data store
      # @return [void]
      def create(*)
        raise NotImplementedError
      end

      # @abstract deletes the tenant data store
      # @return [void]
      def delete(*)
        raise NotImplementedError
      end
    end
  end
end
