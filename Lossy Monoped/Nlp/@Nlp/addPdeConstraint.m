function addPdeConstraint(obj, variable, expression, dependent, varargin)
%ADDPDECONSTRAINT Add a PDE constraint to the NLP problem.
%
% Syntax:
%   obj.addPdeConstraint(variable, expression, dependent);
%
% Required Input Arguments:
%   variable - (EXPRESSIONNODE) Variable being differentiated.
%   expression - (EXPRESSIONNODE) Differential constraint expression.
%   dependent - (EXPRESSIONNODE) Differentiation with respect to.
%
% Optional Input Arguments:
%    method - (CHAR) Integration method.
%   description - (CHAR) Description for identification.

% Copyright 2013-2014 Mikhail S. Jones

  % Construct input argument parser
  parser = inputParser;
  parser.addRequired('variable', ...
    @(x) validateattributes(x, ...
      {'ExpressionNode'}, {'scalar'}));
  parser.addRequired('expression', ...
    @(x) validateattributes(x, ...
      {'ExpressionNode'}, {'scalar'}));
  parser.addRequired('dependent', ...
    @(x) validateattributes(x, ...
      {'ExpressionNode', 'double'}, {'scalar'}));
  parser.addParamValue('method', 'trapezoidal');
  parser.addParamValue('description', '');

	% Parse input arguments
  parser.parse(variable, expression, dependent, varargin{:});

	% Store the results
  opts = parser.Results;

  % Verify proper data types
  % n = max(variable.length, expression.length);
  % variable = variable + ConstantNode(0, n);
  % expression = expression + ConstantNode(0, n);
  % dependent = SymExpression(dependent);

  % TODO
  % Check size of variable and expression
  % Check both are actual variables

  % User feedback
  fprintf('Adding ([\b%d]\b) [\b%s]\b constraints... \n', ...
    expression.length, opts.description);

  % Handle dependent variable options
  if dependent.length == 1
    h = dependent/(expression.length - 1);
  elseif dependent.length == expression.length
    h = ind(dependent,2:dependent.length) - ind(dependent,1:dependent.length-1);%diff(dependent);
  else
    error('coalesce:Nlp:addPdeConstraint', ...
      'Dependant must be scalar or same size as expression.');
  end % if

  switch lower(opts.method)
    case 'explicit euler'; explicitEuler(variable, expression, h);
    case 'implicit euler'; implicitEuler(variable, expression, h);
    case 'trapezoidal'; trapezoidal(variable, expression, h);
    otherwise
      error('coalesce:optimize:Nlp:addPdeConstraint', ...
        'Not a valid integration method.');
  end % switch

  function trapezoidal(x, expr, h)
  %TRAPEZOIDAL Trapezoidal integration scheme.
  %   The trapezoidal scheme is a second order accurate, implicit, two-stage
  %   integration method. (Lobatto IIIA, order 2)
  %
  %   Butcher Array:
  %     0  |  0    0
  %     1  | 1/2  1/2
  %   ----------------
  %        | 1/2  1/2

    % Compute defect
    defect = - ind(x,2:x.length) + ind(x,1:x.length-1) + h*(ind(expr,1:expr.length-1) + ind(expr,2:expr.length))/2;

    % Append object array with more constraints
    obj.constraint(end+1) = Constraint(defect, 0, 0, opts.description);
  end % trapezoidal

  function implicitEuler(x, expr, h)
  %IMPLICITEULER Implicit (Backward) Euler integration scheme.
  %   The implicit Euler scheme is a first order accurate, implicit,
  %   one-stage integration method. (Radau, order 1)
  %
  %   Butcher Array:
  %     0  |  0    0
  %   ----------------
  %        |  0    1

    % Compute defect
    defect = - ind(x,2:x.length) + ind(x,1:x.length-1) + h*ind(expr,2:expr.length);

    % Append object array with more constraints
    obj.constraint(end+1) = Constraint(defect, 0, 0, opts.description);
  end % implicitEuler

  function explicitEuler(x, expr, h)
  %EXPLICITEULER Explicit (Forward) Euler integration scheme.
  %   The explicit Euler scheme is a first order accurate, explicit,
  %   one-stage integration method. (Radau, order 1)
  %
  %   Butcher Array:
  %     0  |  0
  %   -----------
  %        |  1

    % Compute defect
    defect = - ind(x,2:x.length) + ind(x,1:x.length-1) + h*ind(expr,1:expr.length-1);

    % Append object array with more constraints
    obj.constraint(end+1) = Constraint(defect, 0, 0, opts.description);
  end % explicitEuler
end % addPdeConstraint
