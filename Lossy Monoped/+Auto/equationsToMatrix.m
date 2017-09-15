function [A,b] = equationsToMatrix( eq, x )
%EQUATIONSTOMATRIX equationsToMatrix for nonlinear equations
%   factors out the vector x from eq such that eq = Ax + b
%   eq does not need to be linear in x
%   eq must be a vector of equations, and x must be a vector of symbols
%   Copyright 2017 Andy Abate (abatea@oregonstate.edu)

assert(isa(eq,'sym'), 'Equations must be symbolic')
assert(isa(x,'sym'), 'Vector x must be symbolic')

n = numel(eq);
m = numel(x);

A = repmat(sym(0),n,m);

for i = 1:n % loop through equations
    [c,p] = coeffs(eq(i),x); % separate equation into coefficients and powers of x(1)...x(n)
    for k = 1:numel(p) % loop through found powers/coefficients
        for j = 1:m % loop through x(1)...x(n)
            if has(p(k),x(j))
                % transfer term c(k)*p(k) into A, factoring out x(j)
                A(i,j) = A(i,j) + c(k)*p(k)/x(j);
                break % move on to next term c(k+1), p(k+1)
            end
        end
    end
end

b = simplify(eq - A*x,'ignoreanalyticconstraints',true); % makes sure to fully cancel terms

end

