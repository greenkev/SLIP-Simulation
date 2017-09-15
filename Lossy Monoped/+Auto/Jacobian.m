classdef Jacobian < Auto.Base
    %AUTOJACOBIAN Subclass this to automatically generate a symbolic Jacobian. Inherits from Auto.
    %   Copyright 2017 Andy Abate (abatea@oregonstate.edu)
    
    % subclasses must implement this
    methods (Abstract)
        y = eval(o,x)
    end
    
    methods
        function o = Jacobian()
            o.runBuildRule('jacobian',@()build(o))
        end
    end
end

function build(o)
fprintf(['Creating jacobian(x) for ' class(o) '...\n'])
[o,params] = o.makeFieldsSymbolic();
x = o.symbolicStateVariables();

% make function evaluation symbolic
f = reshape(o.eval(x),[],1);
% calculate symbolic jacobian
J = jacobian(f,x);

% export symbolic method
o.writeMethod(J,x,params,'jacobian');
end

