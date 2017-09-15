%ABSUNARYOPERATORNODE Unary absolute value operator node subclass.
%
% Copyright 2014-2016 Mikhail S. Jones

classdef AbsUnaryOperatorNode < UnaryOperatorNode

	% PUBLIC PROPERTIES =====================================================
	methods
		function obj = AbsUnaryOperatorNode(operand)
		%ABSUNARYOPERATORNODE Unary absolute value operator node constructor.
			obj = obj@UnaryOperatorNode(operand);
		end % AbsUnaryOperatorNode
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function y = diff_(obj, x)
		%DIFF_ Overloaded abstract method to differentiate node.

			% Apply chain rule
			y = sign(obj.operand)*diff_(obj.operand, x);
		end % diff_

		function y = eval_(obj)
		%EVAL_ Overloaded abstract method to evaluate node.
			y = abs(eval_(obj.operand));
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

      % Simplification rule (abs(a) = b)
			if isa(obj.operand, 'ConstantNode')
				obj = ConstantNode(abs(obj.operand.value));
			end % if
		end % simplify_

		function str = char_(obj)
		%CHAR_ Overloaded abstract method to convert node to char.
			str = ['AbsUnaryOperatorNode(' char_(obj.operand) ')'];
		end % char_

		function str = matlabCode_(obj)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.
			str = ['abs(' matlabCode_(obj.operand) ')'];
		end % matlabCode_
	end % methods
end % classdef
