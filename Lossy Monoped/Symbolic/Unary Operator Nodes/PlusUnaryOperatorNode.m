%PLUSUNARYOPERATORNODE Unary plus operator node subclass.
%
% Copyright 2014 Mikhail S. Jones

classdef PlusUnaryOperatorNode < UnaryOperatorNode

	% PUBLIC PROPERTIES =====================================================
	methods
		function this = PlusUnaryOperatorNode(operand)
		%PLUSUNARYOPERATORNODE Unary plus operator node constructor.
			this = this@UnaryOperatorNode(operand);
		end % PlusUnaryOperatorNode
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function y = diff_(this, x)
		%DIFF_ Overloaded abstract method to differentiate node.

			% Apply chain rule
			y = diff_(this.operand, x);
		end % diff_

		function y = eval_(this)
		%EVAL_ Overloaded abstract method to evaluate node.
			y = eval_(this.operand);
		end % eval_

		function this = simplify_(this)
		%SIMPLIFY_ Overloaded abstract method to simplify node.

			if this.isSimple
				return;
			else
				this.operand = simplify_(this.operand);
				this.isSimple = true;
			end % if

			if isa(this.operand, 'ConstantNode')
				% Evaluate operator numerically
				this = ConstantNode(eval_(this));
			end % if
		end % simplify_

		function str = char_(this)
		%CHAR_ Overloaded abstract method to convert node to char.
			str = char_(this.operand);
		end % char_

		function str = matlabCode_(this)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.
			str = matlabCode_(this.operand);
		end % matlabCode_
	end % methods
end % classdef
