function pWatt = power_dbm_to_watt(pDbm)
%POWER_DBM_TO_WATT Convert dBm to Watt.

pWatt = 10.^((pDbm - 30)./10);

end
