%PLUSBINARYOPERATORNODE Binary plus operator node subclass.
%
% Copyright 2014-2016 Mikhail S. Jones

classdef PlusBinaryOperatorNode < BinaryOperatorNode

	% PUBLIC METHODS ========================================================
	methods
		function obj = PlusBinaryOperatorNode(left, right)
		%PLUSBINARYOPERATORNODE Binary plus operator node constructor.
			obj = obj@BinaryOperatorNode(left, right);
		end % PlusBinaryOperatorNode
	end % methods

	% PROTECTED METHODS =====================================================
	methods (Access = protected)
		function y = diff_(obj, x)
		%DIFF_ Overloaded abstract method to differentiate node.

			% Apply chain rule
			y = PlusBinaryOperatorNode(diff_(obj.left, x), diff_(obj.right, x));
		end % diff_

		function y = eval_(obj)
		%EVAL_ Overloaded abstract method to evaluate node.
			y = eval_(obj.left) + eval_(obj.right);
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
      
      % Simplification rule (a + b = c)
			if isa(obj.left, 'ConstantNode') && isa(obj.right, 'ConstantNode')
				obj = ConstantNode(obj.left.value + obj.right.value);

      % Simplification rule (0 + x = x)
			elseif isa(obj.left, 'ConstantNode')
				if obj.left.value == 0
					obj = obj.right;
				end % if

      % Simplification rule (x + 0 = x)
			elseif isa(obj.right, 'ConstantNode')
				if obj.right.value == 0
					obj = obj.left;
				end % if

      % Simplification rule (x + x = 2*x)
			elseif isequal(obj.left, obj.right)
				obj = TimesBinaryOperatorNode(2, obj.left);
        
      % Simplification rule (a*x + b*x = (a + b)*x)
      elseif isa(obj.left, 'TimesBinaryOperatorNode') && isa(obj.right, 'TimesBinaryOperatorNode') 
        if isequal(obj.left.right, obj.right.right)
          obj = simplify_(TimesBinaryOperatorNode(...
                  PlusBinaryOperatorNode(...
                    obj.left.left, obj.right.left), ...
                  obj.right.right));
        end % if
        
      % Simplification rule (a*x + x = (a + 1)*x)
      elseif isa(obj.left, 'TimesBinaryOperatorNode') 
        if isequal(obj.left.right, obj.right)
          obj = simplify_(TimesBinaryOperatorNode(...
                  PlusBinaryOperatorNode(...
                    obj.left.left, ConstantNode(1)), ...
                  obj.right));
        end % if
        
      % Simplification rule (x + a*x = (a + 1)*x)
      elseif isa(obj.right, 'TimesBinaryOperatorNode') 
        if isequal(obj.right.right, obj.left)
          obj = simplify_(TimesBinaryOperatorNode(...
                  PlusBinaryOperatorNode(...
                    obj.right.left, ConstantNode(1)), ...
                  obj.left));
        end % if
			end % if
		end % simplify_

		function str = char_(obj)
		%CHAR_ Overloaded abstract method to convert node to char.
			str = ['PlusBinaryOperatorNode(' char_(obj.left) ', ' char_(obj.right) ')'];
		end % char_

		function str = matlabCode_(obj)
		%MATLABCODE_ Overloaded abstract method to convert node to matlab code.
			str = [matlabCode_(obj.left) ' + ' matlabCode_(obj.right)];
		end % matlabCode_
	end % methods
end % classdef
