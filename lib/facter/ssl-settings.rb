require 'facter/util/puppet_settings'

[:localcacert, :hostcrl, :hostcert, :hostprivkey, :hostpubkey].each do |key|
  Facter.add("puppet_#{key}".intern) do
    setcode do
      # This will be nil if Puppet is not available.
      Facter::Util::PuppetSettings.with_puppet do
        Puppet[key]
      end
    end
  end
end
