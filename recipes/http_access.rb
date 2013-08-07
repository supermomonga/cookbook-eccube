
include_recipe 'iptables'

iptables_rule 'http'
iptables_rule 'ssh'
