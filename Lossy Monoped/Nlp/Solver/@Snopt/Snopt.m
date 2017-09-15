%SNOPT Provides an interface for COALESCE objects.
%
% Copyright 2013-2015 Mikhail S. Jones

classdef Snopt < Solver

	% PUBLIC PROPERTIES =====================================================
	properties
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function obj = Snopt(nlp)
		%SNOPT Creates a optimization solver object.

			% Call superclass constructor
			obj = obj@Solver(nlp);

			% Set default SNOPT options
			snscreen('on');
			snseti('Iterations limit', 1e5);
			snseti('Major iterations limit', 5e3);
			snseti('Minor iterations limit', 5e2);
			snsetr('Feasibility tolerance', 1e-6);
			snsetr('Major feasibility tolerance', 1e-6);
			snsetr('Minor feasibility tolerance', 1e-6);
			snsetr('Major optimality tolerance', 1e-6);
		end % Snopt

		function setOptions(obj, userOptions)
		%SETOPTIONS Set optimizer options.

			% Set SNOPT options
			snsetr(userOptions{:});
		end % setOptions
	end % methods
end % classdef
