%FUNCTIONALOPERATORNODE Expression tree functional operator node subclass.
%
% Copyright 2014 Mikhail S. Jones

classdef FunctionalOperatorNode < ExpressionNode

	% PROTECTED PROPERTIES ==================================================
	properties (Access = protected)
		operand@ExpressionNode
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function this = FunctionalOperatorNode(operand)
		%FUNCTIONALOPERATORNODE Functional operator node constructor.

			% Check data type of operand node
			if isa(operand, 'ExpressionNode')
				% Expression node subclasses can be stored as is
				this.operand = operand;
			else
				% Convert into appropriate ExpressionNode subclass
				this.operand = this.convertObject('', operand);
			end % if

			% Set object properties
			this.length = 1;
		end % FunctionalOperatorNode
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
