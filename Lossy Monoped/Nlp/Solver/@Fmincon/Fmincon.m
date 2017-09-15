%FMINCON Provides an interface for COALESCE objects.
%
% Copyright 2013-2015 Mikhail S. Jones

classdef Fmincon < Solver

	% PUBLIC PROPERTIES =====================================================
	properties
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function obj = Fmincon(nlp)
		%FMINCON Creates a optimization solver object.

			% Call superclass constructor
			obj = obj@Solver(nlp);

			% Set default FMINCON options
			obj.options = optimset(...
				'Algorithm', 'interior-point', ...
				'Display', 'iter', ...
				'FinDiffType', 'forward', ...
				'GradConstr', 'on', ...
				'GradObj', 'on', ...
				'Hessian','fin-diff-grads', ...
				...'Hessian','user-supplied', ...
				...'HessMult',@fminconHessMult, ...
				'MaxFunEvals', 1e5, ...
				'SubproblemAlgorithm','cg', ...
				'UseParallel', 'Always');
		end % Fmincon

		function setOptions(obj, userOptions)
		%SETOPTIONS Set optimizer options.

			% Set properties
			opts = {obj.options};
			obj.options = optimset(opts{:}, userOptions{:});
		end % setOptions
	end % methods
end % classdef
