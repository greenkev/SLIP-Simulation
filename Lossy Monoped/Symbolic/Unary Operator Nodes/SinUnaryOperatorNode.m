%SINUNARYOPERATORNODE Unary sine operator node subclass.
%
% Copyright 2014-2016 Mikhail S. Jones

classdef SinUnaryOperatorNode < UnaryOperatorNode

	% PUBLIC PROPERTIES =====================================================
	methods
		function obj = SinUnaryOperatorNode(operand)
		%SINUNARYOPERATORNODE Unary sine operator node constructor.
			obj = obj@UnaryOperatorNode(operand);
		end % SinUnaryOperatorNode
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function y = diff_(obj, x)
		%DIFF_ Overloaded abstract method to differentiate node.

			% Apply chain rule
			y = cos(obj.operand).*diff_(obj.operand, x);
		end % diff_

		function y = eval_(obj)
		%EVAL_ Overloaded abstract method to evaluate node.
			y = sin(eval_(obj.operand));
		end % eval_

		function obj = simplify_(obj)
		%SIMPLIFY_ Overloaded abstract method to simplify node.

			% Simplification lazy check
			if obj.isSimple
				return;
			end % if
      
      % Simplify operand
      obj.operand = simplify_(obj.operand);
      obj.isSimple = true;

			% Simplification rule (sin(a) = b)
			if isa(obj.operand, 'ConstantNode')
				obj = ConstantNode(sin(obj.operand.value));
			end % if
		end % simplify_

		function str = char_(obj)
		%CHAR_ Overloaded abstract method to convert node to char.
			str = ['SinUnaryOperatorNode(' char_(obj.operand) ')'];
		end % char_

		function str = matlabCode_(obj)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.
			str = ['sin(' matlabCode_(obj.operand) ')'];
		end % matlabCode_
	end % methods
end % classdef
