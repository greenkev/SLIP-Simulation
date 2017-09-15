%UNARYOPERATORNODE Expression tree unary operator node subclass.
%
% Copyright 2014 Mikhail S. Jones

classdef UnaryOperatorNode < ExpressionNode

	% PROTECTED PROPERTIES ==================================================
	properties (Access = protected)
		operand@ExpressionNode
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function this = UnaryOperatorNode(operand)
		%UNARYOPERATORNODE Unary operator node constructor.

			% Check data type of operand node
			if isa(operand, 'ExpressionNode')
				% Expression node subclasses can be stored as is
				this.operand = simplify_(operand);
			else
				% Convert into appropriate ExpressionNode subclass
				this.operand = this.convertObject('', operand);
			end % if

			% Set object properties
			this.length = this.operand.length;
		end % UnaryOperatorNode

		function this = ind(this, index)
		%IND Index expression.

			% Copy object and set new index values
			for i = 1:numel(this)
				this(i).operand = ind(this(i).operand, index);
				this(i).length = length(index);
			end % for
		end % ind
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function vars = symvar_(this)
		%SYMVAR_ Determine the variables in an expression tree.

			% Determine variables in branch
			vars = symvar_(this.operand);
		end % symvar_
	end % methods
end % classdef
