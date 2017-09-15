classdef ExpressionNodeTest < matlab.unittest.TestCase

  % TEST METHODS ==========================================================
  methods (Test)
    function testBinaryOperationRules(obj)
      % Construct constant and variables
      c = ConstantNode(1);
      x = VariableNode('x');
      y = VariableNode('y');
      z = VariableNode('z');
      
      x + x == 2*x
      x - x == 0
      x + y == y + x
      x/x == 1
      (x + y)/(x + y) == 1
      
    end % testBinaryOperationRules
    
    function testDifferentiationRules(obj)
      
      % Construct constant and variables
      c = ConstantNode(1);
      a = VariableNode('a');
      x = VariableNode('x');

      % Constant
      obj.verifyTrue(diff(c, c) == 0);
      obj.verifyTrue(diff(c, x) == 0);

      % Variable
      obj.verifyTrue(diff(x, c) == 0);
      obj.verifyTrue(diff(x, x) == 1);

      % Plus
      obj.verifyTrue(diff(x + x, x) == 2);

      % Minus
      obj.verifyTrue(diff(x - x, x) == 0);

      % Times
      obj.verifyTrue(diff(2*x, x) == 2);
      obj.verifyTrue(diff(a*x, x) == a);
      obj.verifyTrue(diff(x*2, x) == 2);
      obj.verifyTrue(diff(x*a, x) == a);

      % Divide
      obj.verifyTrue(diff(2/x, x) == -2/x^2);
      obj.verifyTrue(diff(a/x, x) == -a/x^2);
      obj.verifyTrue(diff(x/2, x) == 1/2);
      obj.verifyTrue(diff(x/a, x) == 1/a);

      % Power
      obj.verifyTrue(diff(x^2, x) == 2*x);
      obj.verifyTrue(diff(2^x, x) == 0.6931471805599453*2^x);

      % Trig
      obj.verifyTrue(diff(sin(x), x) == cos(x));
      obj.verifyTrue(diff(cos(x), x) == -sin(x));
      obj.verifyTrue(diff(tan(x), x) == 1 + tan(x)^2);

      % Other
      obj.verifyTrue(diff(exp(x), x) == exp(x));
      obj.verifyTrue(diff(exp(-x), x) == -exp(-x));
      obj.verifyTrue(diff(log(x), x) == 1/x);
    end % testDifferentiationRules
  end % methods
end % classdef
