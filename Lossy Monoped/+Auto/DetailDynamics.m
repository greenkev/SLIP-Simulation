classdef DetailDynamics < Auto.Dynamics
    %DYNAMICSDETAILED Subclass this to generate symbolic Coriolis, stiffness, and potential terms. Inherits from AutoDynamics.
    %   Copyright 2017 Andy Abate (abatea@oregonstate.edu)
    
    properties (Constant,Access=private)
        targets = {'coriolisMatrix','potentialTerms','stiffnessMatrix'}
    end
    
    methods
        function o = DetailDynamics()
            o.runBuildRule(o.targets,@()build(o,o.targets{:}));
        end
    end
    
end

function build(o,coriolisname,potentialname,stiffnessname)
fprintf(['Creating ' cell2mat(strcat(o.targets,{'(x,xdot), ','(x) and ','(x)'})) ' for ' class(o) '...\n']);

[o,params] = o.makeFieldsSymbolic();
[x,xdot] = o.symbolicStateVariables();

b = o.dynamics(x,xdot); % M(x)*xddot + b(x,xdot) = u
[C,G] = Auto.equationsToMatrix(b,xdot); % C(x,xdot)*xdot + G(x)
K = jacobian(G,x);

% export symbolic methods
o.writeMethod(C,{x,xdot},params,coriolisname);
o.writeMethod(G,x,params,potentialname);
o.writeMethod(K,x,params,stiffnessname);
end
