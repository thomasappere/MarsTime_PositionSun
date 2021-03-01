function kepler, ecc

common kepler, e, m

return, ecc - e*sin(ecc) - m
end

