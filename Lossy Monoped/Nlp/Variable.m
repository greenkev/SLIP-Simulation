%VARIABLE Defines an optimization design variable object.
%
% Description:
%   This class creates an object representing a single decision variable
%   and its properties.
%
% Copyright 2013-2014 Mikhail S. Jones

classdef Variable < VariableNode

	% PUBLIC PROPERTIES =====================================================
	properties
		nlp@Nlp scalar
		description@char vector = ''
	end % properties

	% DEPENDENT PROPERTIES ==================================================
	properties (Dependent = true)
		initialGuess@double vector = []
		solution@double vector = []
		lowerBound@double vector = []
		upperBound@double vector = []
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function this = Variable(name, varargin)
		%VARIABLE Create an optimization design variable object.
			this = this@VariableNode(name, varargin{:});
		end % Variable

		function this = set.initialGuess(this, initialGuess)
		%SET.INITIALGUESS Set method for initial guess property.

			% Check value is correct size
			for i = 1:numel(this)
				if any(length(initialGuess) == [1 this(i).length])
					this(i).nlp.initialGuess(this(i).index) = reshape(initialGuess, 1, []);
				else
					error('Dimensions do not match.');
				end % if
			end % for
		end % set.initialGuess

		function this = set.lowerBound(this, lowerBound)
		%SET.LOWERBOUND Set method for lowerBound property.

			% Check value is correct size
			if any(length(lowerBound) == [1 this.length])
				this.nlp.variableLowerBound(this.index) = reshape(lowerBound, 1, []);
			else
				error('Dimensions do not match.');
			end % if
		end % set.lowerBound

		function this = set.upperBound(this, upperBound)
		%SET.UPPERBOUND Set method for upperBound property.

			% Check value is correct size
			if any(length(upperBound) == [1 this.length])
				this.nlp.variableUpperBound(this.index) = reshape(upperBound, 1, []);
			else
				error('Dimensions do not match.');
			end % if
		end % set.upperBound

		function this = set.solution(this, solution)
		%SET.SOLUTION Set method for solution property.

			% Check solution is correct size
			if length(solution) == this.length
				this.nlp.solution(this.index) = reshape(solution, 1, []);
			else
				error('Dimensions do not match.');
			end % if
		end % set.solution

		function initialGuess = get.initialGuess(this)
		%GET.INITIALGUESS Get method for initial guess property.
				initialGuess = this.nlp.initialGuess(this.index);
		end % get.initialGuess

		function lowerBound = get.lowerBound(this)
		%GET.LOWERBOUND Get method for lowerBound property.
				lowerBound = this.nlp.variableLowerBound(this.index);
		end % get.lowerBound

		function upperBound = get.upperBound(this)
		%GET.UPPERBOUND Get method for upperBound property.
				upperBound = this.nlp.variableUpperBound(this.index);
		end % get.upperBound

		function solution = get.solution(this)
		%GET.SOLUTION Get method for solution property.
				solution = this.nlp.solution(this.index);
		end % get.solution
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function val = eval_(this)
		%EVAL_ Overloaded abstract method to evaluate variable.

			% Return variable solution
			val = reshape(this.solution, 1, []);
		end % eval_
	end % methods
end % classdef
