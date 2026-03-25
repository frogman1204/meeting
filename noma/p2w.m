function pw = p2w(pd)
%P2W Convert dBm to Watt.

pw = 10.^((pd - 30)./10);

end
