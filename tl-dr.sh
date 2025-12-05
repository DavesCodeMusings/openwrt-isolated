# Optionally change default network address
uci set network.lan.ipaddr='192.168.2.1'

# Configure new SSID and Password
uci set wireless.default_radio0.ssid='NewSSID'
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio0.key='NewP@ssw0rd'

# Enable wireless
uci set wireless.radio0.disabled='0'

# Save and activate changes
uci commit
service network reload
