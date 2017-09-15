%TIMESBINARYOPERATORNODE Binary multiplication operator node subclass.
%
% Copyright 2014-2016 Mikhail S. Jones

classdef TimesBinaryOperatorNode < BinaryOperatorNode

	% PUBLIC PROPERTIES =====================================================
	methods
		function obj = TimesBinaryOperatorNode(left, right)
		%TIMESBINARYOPERATORNODE Binary multiplication operator node constructor.
			obj = obj@BinaryOperatorNode(left, right);
		end % TimesBinaryOperatorNode
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function y = diff_(obj, x)
		%DIFF_ Overloaded abstract method to differentiate node.

			% Apply chain rule
			leftDiff = diff_(obj.left, x);
			rightDiff = diff_(obj.right, x);

			% Check if either is zero
			if isa(leftDiff, 'ConstantNode')
				leftZero = leftDiff.value == 0;
			else
				leftZero = false;
			end % if
			if isa(rightDiff, 'ConstantNode')
				rightZero = rightDiff.value == 0;
			else
				rightZero = false;
			end % if

			if leftZero && rightZero
				y = ConstantNode(0);
			elseif leftZero
				y = TimesBinaryOperatorNode(obj.left, rightDiff);
			elseif rightZero
				y = TimesBinaryOperatorNode(obj.right, leftDiff);
			else
				% Apply chain rule
				y = PlusBinaryOperatorNode(...
							TimesBinaryOperatorNode(obj.left, rightDiff), ...
							TimesBinaryOperatorNode(obj.right, leftDiff));
			end % if
		end % diff_

		function y = eval_(obj)
		%EVAL_ Overloaded abstract method to evaluate node.
			y = eval_(obj.left).*eval_(obj.right);
		end % eval_

		function obj = simplify_(obj)
		%SIMPLIFY_ Overloaded abstract method with to simplify node.

      % Simplification lazy check
			if obj.isSimple
				return;
			end % if
      
      % Simplify LHS and RHS
      obj.left = simplify_(obj.left);
			obj.right = simplify_(obj.right);
      obj.isSimple = true;

      % Simplification rule (a * b = c)
			if isa(obj.left, 'ConstantNode') && isa(obj.right, 'ConstantNode')
				obj = ConstantNode(obj.left.value.*obj.right.value);

			elseif isa(obj.left, 'ConstantNode')
        % Simplification rule (0 * x = 0)
				if obj.left.value == 0
					obj = ConstantNode(0);

        % Simplification rule (-1 * x = -x)
				elseif obj.left.value == -1
					obj = MinusUnaryOperatorNode(obj.right);

        % Simplification rule (1 * x = x)
				elseif obj.left.value == 1
					obj = obj.right;
				end % if

			elseif isa(obj.right, 'ConstantNode')
				% Simplification rule (x * 0 = 0)
        if obj.right.value == 0
          obj = ConstantNode(0);

        % Simplification rule (x * -1 = -x)
        elseif obj.right.value == -1
          obj = MinusUnaryOperatorNode(obj.left);

        % Simplification rule (x * 1 = x)
        elseif obj.right.value == 1
          obj = obj.left;
        end % if

      % Simplification rule (x * x = x^2)
			elseif isequal(obj.left, obj.right)
				obj = PowerBinaryOperatorNode(obj.left, ConstantNode(2));
        
      % Simplification rule (x^a * x^b = x^(a + b))
      elseif isa(obj.left, 'PowerBinaryOperatorNode') && isa(obj.right, 'PowerBinaryOperatorNode') 
        if isequal(obj.left.left, obj.right.left)
          obj = simplify_(PowerBinaryOperatorNode(...
                  obj.left.left, ...
                  PlusBinaryOperatorNode(...
                    obj.left.right, obj.right.right)));
        end % if
        
      % Simplification rule (x^a * x = x^(a + 1))
      elseif isa(obj.left, 'PowerBinaryOperatorNode') 
        if isequal(obj.left.left, obj.right)
          obj = simplify_(PowerBinaryOperatorNode(...
                  obj.right, ...
                  PlusBinaryOperatorNode(...
                    obj.left.right, ConstantNode(1))));
        end % if
        
      % Simplification rule (x * x^a = x^(a + 1))
      elseif isa(obj.right, 'PowerBinaryOperatorNode') 
        if isequal(obj.right.left, obj.left)
          obj = simplify_(PowerBinaryOperatorNode(...
                  obj.left, ...
                  PlusBinaryOperatorNode(...
                    obj.right.right, ConstantNode(1))));
        end % if
			end % if
		end % simplify_

		function str = char_(obj)
		%CHAR_ Overloaded abstract method to convert node to char.
			str = ['TimesBinaryOperatorNode(' char_(obj.left) ', ' char_(obj.right) ')'];
		end % char_

		function str = matlabCode_(obj)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.
    
      % Check if parenthesis are needed around LHS
      if isa(obj.left, 'PlusBinaryOperatorNode') || isa(obj.left, 'MinusBinaryOperatorNode')
        leftStr = ['(' matlabCode_(obj.left) ')'];
      else
        leftStr = matlabCode_(obj.left);
      end % if
      
      % Check if parenthesis are needed around RHS
      if isa(obj.right, 'PlusBinaryOperatorNode') || isa(obj.right, 'MinusBinaryOperatorNode')
        rightStr = ['(' matlabCode_(obj.right) ')'];
      else
        rightStr = matlabCode_(obj.right);
      end % if
      
      % Concatenate LHS and RHS into string
      str = [leftStr '.*' rightStr];
		end % matlabCode_
	end % methods
end % classdef
