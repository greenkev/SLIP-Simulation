%OBJECTIVE Defines an optimization objective object.
%
% Description:
%   This class creates an object representing a single objective function
%   and its properties.
%
% Copyright 2013-2014 Mikhail S. Jones

classdef Objective

	% PUBLIC PROPERTIES =====================================================
	properties
		description@char vector
		expression@ExpressionNode scalar
		lowerBound@double scalar
		upperBound@double scalar
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function this = Objective(expression, description)
		%OBJECTIVE Construct an optimization objective object.
		%
		% Syntax:
		%   obj = Objective(expression, description)
		%
		% Inputs Arguments:
		%   expression - (EXPRESSIONNODE) Symbolic objective expression
		%   description - (CHAR) Description for identification

			% Allow creation of empty objects
			if nargin ~= 0
				% Set object properties
				this.expression = simplify(expression);
				this.lowerBound = -Inf;
				this.upperBound = Inf;
				this.description = description;
			end % if
		end % Objective

		function value = eval(this)
		%EVAL Evaluate objective.
			value = eval(this.expression);
		end % eval
	end % methods
end % classdef
