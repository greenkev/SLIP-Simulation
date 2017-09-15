function solve(obj)
%SOLVE Solve optimization problem using MATLAB FMINCON.
%
% Copyright 2013-2015 Mikhail S. Jones

	% User feedback
	fprintf('Initializing FMINCON solver... \n');

	% Refresh function and file system caches
	rehash;

	% Evaluate fminconUser function to determine constants
	[A, b, Aeq, beq] = fminconUser;
	lb = obj.nlp.variableLowerBound;
	ub = obj.nlp.variableUpperBound;
	x0 = obj.nlp.initialGuess;

	% Run FMINCON
	[x, f, obj.info] = fmincon('fminconObj', ...
		x0, A, b, Aeq, beq, lb, ub, 'fminconNonlcon', obj.options);

	% Parse solution back into variable objects
	obj.nlp.solution = x;

	% Send desktop notification
% 	message = ['FMINCON optimizer finished.'...
% 		'\n\t* Exit flag: ' num2str(obj.info)...
% 		'\n\t* Objective value: ' num2str(f)];
% 	notify(message, 'COALESCE', 1);
end % solve
