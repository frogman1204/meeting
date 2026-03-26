function ee = calc_ee(sum_rate, total_power)
%CALC_EE Energy efficiency.

if total_power <= 0
    ee = 0;
else
    ee = sum_rate / total_power;
end

end
