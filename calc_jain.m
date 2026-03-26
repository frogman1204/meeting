function j = calc_jain(R1, R2)
%CALC_JAIN Jain fairness for two-user case.

den = 2*(R1^2 + R2^2);
if den == 0
    j = 0;
else
    j = (R1 + R2)^2 / den;
end

end
