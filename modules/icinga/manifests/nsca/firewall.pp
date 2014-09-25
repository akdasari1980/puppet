# = Class: icinga::nsca::firewall
#
# Sets up firewall rules to allow NSCA traffic on port 5667
class icinga::nsca::firewall {
    # NSCA on port 5667
    ferm::rule { 'ncsa_allowed':
        rule => 'saddr (127.0.0.1 $EQIAD_PRIVATE_ANALYTICS1_A_EQIAD $EQIAD_PRIVATE_ANALYTICS1_B_EQIAD $EQIAD_PRIVATE_ANALYTICS1_C_EQIAD $EQIAD_PRIVATE_ANALYTICS1_D_EQIAD $EQIAD_PRIVATE_LABS_HOSTS1_A_EQIAD $EQIAD_PRIVATE_LABS_HOSTS1_B_EQIAD $EQIAD_PRIVATE_LABS_HOSTS1_D_EQIAD $EQIAD_PRIVATE_LABS_SUPPORT1_C_EQIAD $EQIAD_PRIVATE_PRIVATE1_A_EQIAD $EQIAD_PRIVATE_PRIVATE1_B_EQIAD $EQIAD_PRIVATE_PRIVATE1_C_EQIAD $EQIAD_PRIVATE_PRIVATE1_D_EQIAD $EQIAD_PUBLIC_PUBLIC1_A_EQIAD $EQIAD_PUBLIC_PUBLIC1_B_EQIAD $EQIAD_PUBLIC_PUBLIC1_C_EQIAD $EQIAD_PUBLIC_PUBLIC1_D_EQIAD $ESAMS_PRIVATE_PRIVATE1_ESAMS $ESAMS_PUBLIC_PUBLIC_SERVICES $PMTPA_PRIVATE_PRIVATE $PMTPA_PRIVATE_VIRT_HOSTS $PMTPA_PUBLIC_PUBLIC_SERVICES $PMTPA_PUBLIC_PUBLIC_SERVICES_2 $PMTPA_PUBLIC_SANDBOX $PMTPA_PUBLIC_SQUID_LVS $ULSFO_PRIVATE_PRIVATE1_ULSFO $ULSFO_PUBLIC_PUBLIC1_ULSFO 208.80.155.0/27 10.64.40.0/24) proto tcp dport 5667 ACCEPT;'
    }
}
