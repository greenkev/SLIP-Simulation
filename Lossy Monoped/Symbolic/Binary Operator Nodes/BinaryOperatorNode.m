%BINARYOPERATORNODE Expression tree binary operator node subclass.
%
% Copyright 2014-2016 Mikhail S. Jones

classdef BinaryOperatorNode < ExpressionNode

	% PROTECTED PROPERTIES ==================================================
	properties (Access = protected)
		left@ExpressionNode
		right@ExpressionNode
	end % properties

	% PUBLIC METHODS ========================================================
	methods
		function obj = BinaryOperatorNode(left, right)
		%BINARYOPERATORNODE Binary operator node constructor.      
      
			% Check data type of left node
			if isa(left, 'ExpressionNode')
				% Expression node subclasses can be stored as is
				obj.left = simplify_(left);
			else
				% Convert into appropriate ExpressionNode subclass
				obj.left = obj.convertObject('', left);
			end % if

			% Check data type of right node
			if isa(right, 'ExpressionNode')
				% Expression node subclasses can be stored as is
				obj.right = simplify_(right);
			else
				% Convert into appropriate ExpressionNode subclass
				obj.right = obj.convertObject('', right);
			end % if

			% Check internal dimensions
			if obj.left.length ~= obj.right.length
				if obj.left.length ~= 1 && obj.right.length ~= 1
					error('Dimensions do not match.');
				end % if
			end % if

			% Set object properties
			obj.length = max(obj.left.length, obj.right.length);
		end % BinaryOperatorNode

		function obj = ind(obj, index)
		%IND Index expression.

			% Copy object and set new index values
			for i = 1:numel(obj)
				obj(i).left = ind(obj(i).left, index);
				obj(i).right = ind(obj(i).right, index);
				obj(i).length = length(index);
			end % for
		end % ind
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function vars = symvar_(obj)
		%SYMVAR_ Determine the variables in an expression tree.

			% Determine variables in branches
			leftVars = symvar_(obj.left);
			rightVars = symvar_(obj.right);

			% Create uniqueness index
			ind = ones(size(rightVars));

			% Return only unique variables
			for i = 1:numel(rightVars)
				for j = 1:numel(leftVars)
					if rightVars(i) == leftVars(j)
						ind(i) = 0;
					end % if
				end % for
			end % for

			vars = [leftVars rightVars(find(ind))];
		end % symvar_
	end % methods
end % classdef
