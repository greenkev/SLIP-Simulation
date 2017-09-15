%DIVIDEBINARYOPERATORNODE Binary division operator node subclass.
%
% Copyright 2014-2016 Mikhail S. Jones

classdef PowerBinaryOperatorNode < BinaryOperatorNode

	% PUBLIC PROPERTIES =====================================================
	methods
		function obj = PowerBinaryOperatorNode(left, right)
		%POWERBINARYOPERATORNODE Binary power operator node constructor.
			obj = obj@BinaryOperatorNode(left, right);
		end % PowerBinaryOperatorNode
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
				leftZero = eval_(leftDiff) == 0;
			else
				leftZero = false;
			end % if
			if isa(rightDiff, 'ConstantNode')
				rightZero = eval_(rightDiff) == 0;
			else
				rightZero = false;
			end % if

			if leftZero && rightZero
				y = ConstantNode(0);
			elseif rightZero
        % y = obj.right.*leftDiff.*(obj.left.^(obj.right - 1));
        y = TimesBinaryOperatorNode(...
              TimesBinaryOperatorNode(...
                obj.right, leftDiff), ...
              PowerBinaryOperatorNode(...
                obj.left, MinusBinaryOperatorNode(...
                  obj.right, ConstantNode(1))));
			else
				% y = obj.left.^obj.right.*(leftDiff.*obj.right./obj.left + rightDiff.*log(obj.left));
        y = TimesBinaryOperatorNode(...
              PowerBinaryOperatorNode(...
                obj.left, obj.right), ...
              PlusBinaryOperatorNode(...
                DivideBinaryOperatorNode(...
                  TimesBinaryOperatorNode(...
                    leftDiff, obj.right), ...
                  obj.left), ...
                TimesBinaryOperatorNode(...
                  rightDiff, LogUnaryOperatorNode(obj.left))));
			end % if
		end % diff_

		function y = eval_(obj)
		%EVAL_ Overloaded abstract method to evaluate node.
			y = eval_(obj.left).^eval_(obj.right);
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

      % Simplification rule (a^b = c)
			if isa(obj.left, 'ConstantNode') && isa(obj.right, 'ConstantNode')
				obj = ConstantNode(obj.left.value.^obj.right.value);

      % Simplification rule (1^x = 1)
			elseif isa(obj.left, 'ConstantNode')
				if obj.left.value == 1
					obj = ConstantNode(1);
				end % if

			elseif isa(obj.right, 'ConstantNode')
				% Simplification rule (x^0 = 1)
        if obj.right.value == 0
          obj = ConstantNode(1);

        % Simplification rule (x^1 = x)
        elseif obj.right.value == 1
          obj = obj.left;

        % Simplification rule (x^-1 = 1 / x)
        elseif obj.right.value == -1
          obj = DivideBinaryOperatorNode(ConstantNode(1), obj.left);
        end % if
        
      % Simplification rule (x^a * x^b = x^(a + b)
      % TODO
      
      % Simplification rule (a^x * b^x = (a * b)^x
      % TODO
			end % if
		end % simplify_

		function str = char_(obj)
		%CHAR_ Overloaded abstract method to convert node to char.
			str = ['PowerBinaryOperatorNode(' char_(obj.left) ', ' char_(obj.right) ')'];
		end % char_

		function str = matlabCode_(obj)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.
    
      % Check if parenthesis are needed around LHS
      if isa(obj.left, 'BinaryOperatorNode')
        leftStr = ['(' matlabCode_(obj.left) ')'];
      else
        leftStr = matlabCode_(obj.left);
      end % if

      % Check if parenthesis are needed around RHS
      if isa(obj.right, 'BinaryOperatorNode')
        rightStr = ['(' matlabCode_(obj.right) ')'];
      else
        rightStr = matlabCode_(obj.right);
      end % if

      % Concatenate LHS and RHS into string
      str = [leftStr '.^' rightStr];
		end % matlabCode_
	end % methods
end % classdef
