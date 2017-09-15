%SUMUNARYOPERATORNODE Unary summation operator node subclass.
%
% Copyright 2014 Mikhail S. Jones

classdef SumUnaryOperatorNode < FunctionalOperatorNode

	% PUBLIC PROPERTIES =====================================================
	methods
		function this = SumUnaryOperatorNode(operand)
		%SUMUNARYOPERATORNODE Functional summation operator node constructor.
			this = this@FunctionalOperatorNode(operand);
		end % SumUnaryOperatorNode
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function y = diff_(this, x)
		%DIFF_ Overloaded abstract method to differentiate node.

			% Apply chain rule
			y = diff_(this.operand, x);
      y.length = this.operand.length;
		end % diff_

		function y = eval_(this)
		%EVAL_ Overloaded abstract method to evaluate node.
			y = sum(eval_(this.operand));
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
			str = ['sum(' char_(this.operand) ')'];
		end % char_

		function str = matlabCode_(this)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.
			str = ['sum(' matlabCode_(this.operand) ')'];
		end % matlabCode_
	end % methods
end % classdef
