%SOLVER Provides a solver interface for COALESCE Nlp objects.
%
% Description:
%   Abstract class defining solver interfaces to the COALESCE NLPs.
%
% Copyright 2013-2015 Mikhail S. Jones

classdef (Abstract = true) Solver < handle

	% PUBLIC PROPERTIES =====================================================
	properties
		nlp@Nlp scalar
		options@struct
		info
        path
	end % properties

	% ABSTRACT METHODS ======================================================
	methods (Abstract = true)
		export
		solve
	end % methods

	% PUBLIC METHODS ========================================================
	methods
		function obj = Solver(nlp)
		%SOLVER Creates a optimization solver object.
            obj.path = fullfile(pwd,'_build');
			% Set object properties
			obj.nlp = nlp;

			% Create directory for auto generated files if it doesn't exist
			if ~exist(obj.path, 'dir')
				% Make directory
				mkdir(obj.path);
			end % if

			% Set path to auto generated functions
			addpath(obj.path);
		end % Solver
	end % methods
end % classdef
