%CONSTANTNODE Expression tree constant node subclass.
%
% Copyright 2014-2016 Mikhail S. Jones

classdef ConstantNode < ExpressionNode

	% PROTECTED PROPERTIES ==================================================
	properties (SetAccess = protected)
		value@double vector
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function obj = ConstantNode(value)
		%CONSTANTNODE Constant node constructor.

			% Set object properties
			obj.value = value;
			obj.length = length(value);
			obj.isSimple = true;
		end % ConstantNode

		function obj = ind(obj, index)
		%IND Index expression.

			if obj.length ~= 1
				obj.value = obj.value(index);
			end % if
		end % ind
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function y = diff_(~, ~)
		%DIFF_ Overloaded abstract method to differentiate constant node.

			% The derivative of a constant is always zero
			y = ConstantNode(0);
		end % diff_

		function y = eval_(obj)
		%EVAL_ Overloaded abstract method to evaluate constant node.
			y = obj.value;
		end % eval_

		function obj = simplify_(obj)
		%SIMPLIFY_ Overloaded abstract method to simplify constant node.
			% A constant node cannot not be simplified anymore
		end % simplify_

		function vars = symvar_(~)
		%SYMVAR_ Determine the variables in an expression tree.
			vars = [];
		end % symvar_

		function str = char_(obj)
		%CHAR_ Overloaded abstract method to convert constant node to char.

			% Convert numeric value to string keeping double precision
      str = sprintf('%g,', obj.value);
		  str = ['ConstantNode([' str(1:end-1) '])'];
		end % char_

		function str = matlabCode_(obj)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.

			if obj.length == 1
				% Convert numeric value to string keeping double precision
				str = sprintf('%.*f', ceil(-log10(eps(obj.value))), obj.value);

				% Remove trailing zeros
				tmp = regexp(str, '^0+(?!\.)|(?<!\.)0+$', 'split');
				str = tmp{1};

			else
				str = sprintf('%g,', obj.value);
				str = ['[' str(1:end-1) ']'];
			end % if
		end % matlabCode_
	end % methods
end % classdef
