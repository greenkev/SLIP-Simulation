function solve(obj)
%SOLVE Solve optimization problem using IPOPT.
%
% Copyright 2013-2015 Mikhail S. Jones

	% User feedback
% 	fprintf('Initializing IPOPT solver... \n');

	% Refresh function and file system caches
	rehash;

	% Set IPOPT options
	obj.options.lb = obj.nlp.variableLowerBound;
	obj.options.ub = obj.nlp.variableUpperBound;
	obj.options.cl = [obj.nlp.constraint.lowerBound];
	obj.options.cu = [obj.nlp.constraint.upperBound];

	% Set IPOPT functions
	funcs.objective = @ipoptObjective;
	funcs.gradient = @ipoptGradient;
	funcs.constraints = @ipoptConstraints;
	funcs.jacobian = @ipoptJacobian;
	funcs.jacobianstructure = @ipoptJacobianStructure;
	if obj.iterationPlot
		funcs.iterfunc = @ipoptIterFunc;
	end % if

	% Note: Unused functions
	% funcs.hessian = @ipoptHessian;
	% funcs.hessianstructure = @ipoptHessianStructure;

	% Run IPOPT
	[x, obj.info] = ipopt(obj.nlp.initialGuess, funcs, obj.options);

	% Parse solution back into variable objects
	obj.nlp.solution = x;
    
    obj.info.objective = funcs.objective(x);

% 	% Send desktop notification
% 	message = ['IPOPT optimizer finished.'...
% 		'\n\t* Exit flag: ' num2str(obj.info.status)...
% 		'\n\t* Objective value: ' num2str(ipoptObjective(x))];
% 	notify(message, 'COALESCE', 1);
end % solve

function stop = ipoptIterFunc(nIter, f, auxdata)
%IPOPTITERFUNC Ipopt iteration function GUI.

	persistent flag;
	persistent hg;

	% Initialize plots
	if nIter == 0
		flag = true;

		hg.fig = figure;
		subplot(3,1,1);	hg.inf_pr = semilogy(nIter, auxdata.inf_pr, '.-r');
		hold on; grid on; box on;
		ylabel('Primal Infeasiblity');
		xlabel('Iteration');

		subplot(3,1,2);	hg.inf_du = semilogy(nIter, auxdata.inf_du, '.-b');
		hold on; grid on; box on;
		ylabel('Dual Infeasiblity');
		xlabel('Iteration');

		subplot(3,1,3);	hg.f = semilogy(nIter, f, '.-m');
		hold on; grid on; box on;
		ylabel('Objective');
		xlabel('Iteration');

		uicontrol(...
			'Style', 'pushbutton', ...
			'String', 'Stop',...
			'Units', 'normalized', ...
			'Position', [0 0 1 0.05],...
			'Callback', @stopCallback);
	end % if

	% Update plots
	if mod(nIter, 5) == 0
		set(hg.inf_pr, ...
			'XData', [get(hg.inf_pr, 'XData') nIter], ...
			'YData', [get(hg.inf_pr, 'YData') auxdata.inf_pr]);
		set(hg.inf_du, ...
			'XData', [get(hg.inf_du, 'XData') nIter], ...
			'YData', [get(hg.inf_du, 'YData') auxdata.inf_du]);
		set(hg.f, ...
			'XData', [get(hg.f, 'XData') nIter], ...
			'YData', [get(hg.f, 'YData') f]);
		drawnow;
	end % if

	% Set output stop command
	stop = flag;

	function stopCallback(varargin)
	%STOPCALLBACK Stop button callback function.
		flag = false;
	end % stopCallback
end % ipoptIterFunc
