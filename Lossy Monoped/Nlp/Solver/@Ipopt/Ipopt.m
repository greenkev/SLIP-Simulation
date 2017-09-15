%IPOPT Provides an interface for COALESCE objects.
%
% Copyright 2013-2015 Mikhail S. Jones

classdef Ipopt < Solver

	% PUBLIC PROPERTIES =====================================================
	properties
		iterationPlot@logical = false % Option for display iteration plot
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function obj = Ipopt(nlp)
		%IPOPT Creates a optimization solver object.

			% Call superclass constructor
			obj = obj@Solver(nlp);

			% Set default IPOPT options
			obj.options = struct;
			obj.options.ipopt.hessian_approximation = 'limited-memory';

			% Note: mumps linear solver is deterministic but approximately twice
			% as slow as ma57 in many cases. ma57 is non-deterministic due to
			%	parallelization and memory allocation variations.
			obj.options.ipopt.linear_solver = 'ma57';

			% Note: Can use first or second-order check, useful for debugging.
			obj.options.ipopt.derivative_test = 'none';
		end % Ipopt

		function setOptions(obj, varargin)
		%SETOPTIONS Set optimizer options.
    %
    % Notes:
    %   See IPOPT documentation for all solver options
    %   (http://www.coin-or.org/Ipopt/documentation/node40.html)

			% Set IPOPT options
			for i = 1:2:numel(nargin)
				obj.options.ipopt.(varargin{i}) = varargin{i+1};
			end % for
		end % setOptions
	end % methods
end % classdef
