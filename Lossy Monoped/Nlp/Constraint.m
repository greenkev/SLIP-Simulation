%CONSTRAINT Defines an optimization constraint object.
%
% Description:
%   This method creates a constraint or array of constraints of the form,
%   lb <= f(x) + A*x <= ub. The bounds must be either scalar or a defined
%   parameter. The constraint must be a function of design variables and
%   parameters, either linear or nonlinear.
%
% Copyright 2013-2014 Mikhail S. Jones

classdef Constraint

	% PUBLIC PROPERTIES =====================================================
	properties
		description@char vector
		expression@ExpressionNode scalar
		lowerBound@double% scalar
		upperBound@double% scalar
	end % properties

	% PUBLIC METHODS ========================================================
	methods (Access = public)
		function this = Constraint(expression, lowerBound, upperBound, description)
		%CONSTRAINT Construct an optimization constraint object.
		%
		% Syntax:
		%   obj = Constraint(expression, lowerBound, upperBound, description)
		%
		% Inputs Arguments:
		%   expression - (EXPRESSIONNODE) Symbolic constraint expression
		%   lowerBound - (DOUBLE) Numeric lower bounds
		%   upperBound - (DOUBLE) Numeric upper bounds
		%   description - (CHAR) Description for identification

			% Allow creation of empty objects
			if nargin ~= 0
				% Check bounds
				if lowerBound > upperBound
					error('coalesce:optimize:Constraint', ...
						'Lower bounds must be less than upper bounds.');
				end % if

				% Set object properties
				this.expression = simplify(expression);
				this.lowerBound(1:expression.length) = lowerBound;
				this.upperBound(1:expression.length) = upperBound;
				this.description = description;
			end % if
		end % Constraint

		function value = eval(this)
		%EVAL Evaluate constraint.
			value = eval(this.expression);
		end % eval
	end % methods
end % classdef
