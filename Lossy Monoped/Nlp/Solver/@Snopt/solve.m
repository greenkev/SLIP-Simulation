function solve(obj)
%SOLVE Solve optimization problem using SNOPT.
%
% Copyright 2013-2015 Mikhail S. Jones

	% User feedback
	fprintf('Initializing SNOPT solver... \n');

	% Objective function information
	ObjAdd = 0; ObjRow = 1;

	% Refresh function and file system caches
	rehash;

	% Evaluate snoptUser function to determine constants
	[A, iAfun, jAvar, iGfun, jGvar] = snoptUser;
	xlow = obj.nlp.variableLowerBound';
	xupp = obj.nlp.variableUpperBound';
	Flow = [obj.nlp.objective.lowerBound obj.nlp.constraint.lowerBound]';
	Fupp = [obj.nlp.objective.upperBound obj.nlp.constraint.upperBound]';
	x0 = obj.nlp.initialGuess';

	% Run SNOPT
	[x, f, obj.info] = snopt(x0, xlow, xupp, Flow, Fupp, ...
		'snoptUserFun', ObjAdd, ObjRow, A, iAfun, jAvar, iGfun, jGvar);

	% Parse solution back into variable objects
	obj.nlp.solution = x';

	% Send desktop notification
% 	message = ['SNOPT optimizer finished.'...
% 		'\n\t* Exit flag: ' num2str(obj.info)...
% 		'\n\t* Objective value: ' num2str(f(ObjRow) + ObjAdd)];
% 	notify(message, 'COALESCE', 1);
end % solve
