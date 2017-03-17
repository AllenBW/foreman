module FogExtensions
  module Openstack
    module Server
      def self.prepended(base)
        class << base
          attr_reader :nics
          attr_accessor :boot_from_volume, :size_gb, :scheduler_hint_filter
          attr_writer :security_group, :network # floating IP
        end
      end

      def to_s
        name
      end

      def start
        if state.downcase == 'paused'
          service.unpause_server(id)
        else
          service.resume_server(id)
        end
      end

      def stop
        service.suspend_server(id)
      end

      def pause
        service.pause_server(id)
      end

      def tenant
        service.tenants.detect{|t| t.id == tenant_id }
      end

      def flavor_with_object
        service.flavors.get attributes[:flavor]['id']
      end

      def created_at
        Time.parse(attributes['created']).utc
      end

      # the original method requires a server ID, however we want to be able to call this method on new instances too
      def security_groups
        return [] if id.nil?
        super
      end

      def boot_from_volume
        attr[:boot_from_volume]
      end

      def size_gb
        attr[:size_gb]
      end

      def network
        return @network if @network # in case we didnt submitting the form again after an error.
        return networks.try(:first).try(:name) if persisted?
        nil
      end

      def security_group
        return @security_group if @security_group # in case we didnt submitting the form again after an error.
        return security_groups.try(:first).try(:name) if persisted?
        nil
      end

      def reset
        reboot('HARD')
      end

      def vm_description
        service.flavors.get(flavor_ref).try(:name)
      end
    end
  end
end
