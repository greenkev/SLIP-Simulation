%COSUNARYOPERATORNODE Unary cosine operator node subclass.
%
% Copyright 2014-2016 Mikhail S. Jones

classdef CosUnaryOperatorNode < UnaryOperatorNode

	% PUBLIC PROPERTIES =====================================================
	methods
		function obj = CosUnaryOperatorNode(operand)
		%COSUNARYOPERATORNODE Unary cosine operator node constructor.
			obj = obj@UnaryOperatorNode(operand);
		end % CosUnaryOperatorNode
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function d = diff_(obj, x)
		%DIFF_ Overloaded abstract method to differentiate node.

			% Compute derivative of operand
			operandDiff = diff_(obj.operand, x);

			% Apply chain rule
			d = -sin(obj.operand)*operandDiff;
		end % diff_

		function val = eval_(obj)
		%EVAL_ Overloaded abstract method to evaluate node.
			val = cos(eval_(obj.operand));
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

			% Simplification rule (cos(a) = b)
			if isa(obj.operand, 'ConstantNode')
				obj = ConstantNode(cos(obj.operand.value));
			end % if
		end % simplify_

		function str = char_(obj)
		%CHAR_ Overloaded abstract method to convert node to char.
			str = ['CosUnaryOperatorNode(' char_(obj.operand) ')'];
		end % char_

		function str = matlabCode_(obj)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.
			str = ['cos(' matlabCode_(obj.operand) ')'];
		end % matlabCode_
	end % methods
end % classdef
