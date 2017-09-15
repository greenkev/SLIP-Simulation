%VARIABLENODE Expression tree variable node subclass.
%
% TODO: Use length input and have a core engine determine available indexes
% TODO: diff or trapz or some equivalent so user doesn't have use ind
%
% Copyright 2014-2016 Mikhail S. Jones

classdef VariableNode < ExpressionNode

	% PROTECTED PROPERTIES ==================================================
	properties (SetAccess = protected)
		name@char vector
		index@double vector
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function obj = VariableNode(name, index)
		%VARIABLENODE Variable node constructor.

			% Check number of input arguments
			switch nargin
			case 1
				% Construct scalar variable
				obj.index = 1;

			case 2
				% Check length is positive integer
				if all(index > 0) && all(mod(index,1) == 0)
					% Construct vector variable with specified indexes
					obj.index = index;
				else
					error('Indexes must be a positive integers.');
				end % if

			otherwise
				error('Invalid number of input arguments.');
			end % switch

			% Set object properties
			obj.name = name;
			obj.length = length(obj.index);
			obj.isSimple = true;
		end % VariableNode

		function obj = ind(obj, index)
		%IND Index expression.

			% Copy object and set new index values
			for i = 1:numel(obj)
				if obj(i).length ~= 1
					obj(i).index = obj(i).index(index);
					obj(i).length = length(obj(i).index);
				end % if
			end % for
		end % ind

		function obj = initial(obj)
		%INITIAL Initial index expression.

			% Copy object and set new index values
			for i = 1:numel(obj)
				obj(i).index = obj(i).index(1);
				obj(i).length = 1;
			end % for
		end % initial

		function obj = final(obj)
		%FINAL Final index expression.

			% Copy object and set new index values
			for i = 1:numel(obj)
				obj(i).index = obj(i).index(end);
				obj(i).length = 1;
			end % for
		end % final
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function y = diff_(obj, x)
		%DIFF_ Overloaded abstract method to differentiate variable node.

			% Check if differentiation variable matches variable node
			if isequal(obj, x)
				% The derivative of a variable with respect to itself is one
				y = ConstantNode(1);
			else
				% The derivative of a variable with respect to another is zero
				y = ConstantNode(0);
			end % if
		end % diff_

		function eval_(~)
		%EVAL_ Overloaded abstract method to evaluate variable node.

			% A variable node can not be evaluated
			error('Cannot evaluate variable nodes.');
		end % eval_

		function obj = simplify_(obj)
		%SIMPLIFY_ Overloaded abstract method to simplify variable node.
      % A variable node cannot not be simplified anymore
		end % simplify_

		function obj = symvar_(obj)
		%SYMVAR_ Determine the variables in an expression tree.
		end % symvar_

		function str = char_(obj)
		%CHAR_ Overloaded abstract method to convert variable node to char.

			% Convert into indexed variable
			str = ['VariableNode(''' obj.name ''', ' indexHelper(obj.index) ')'];
		end % char_

		function str = matlabCode_(obj)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.

			% Convert into indexed variable
			str = [obj.name '(' indexHelper(obj.index) ')'];
		end % matlabCode_
	end % methods
end % classdef

function str = indexHelper(index)
%INDEXHELPER Convert vector to shorthand index.

	% Check if index is all the same
	if all(diff(index) == 0)
		% Keep index in shorthand scalar form (2)
		str = sprintf('%d', index(1));

	% Check if index is monotonically increasing
	elseif all(diff(diff(index)) == 0)
		% Keep index in shorthand vectorized form (2:5)
		str = sprintf('%d:%d:%d', index(1), index(2) - index(1), index(end));

	else
		% Expand index into explicit vector ([2,3,4,5])
		str = sprintf('%d ', reshape(index, 1, []));
		str = str(1:end-1);
	end % if
end % indexHelper
