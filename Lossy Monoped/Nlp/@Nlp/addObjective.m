function addObjective(obj, expression, varargin)
%ADDOBJECTIVE Add an objective to the NLP problem.
%
% Syntax:
%   obj.addObjective(expression);
%
% Required Input Arguments:
%   expression - (EXPRESSIONNODE) Symbolic objective expression.
%
% Optional Input Arguments:
%   description - (CHAR) Objective description.

% Copyright 2013-2015 Mikhail S. Jones

  % Construct input argument parser
  parser = inputParser;
  parser.addParamValue('description', 'No Name', ...
    @(x) validateattributes(x, ...
      {'char'}, {'vector'}));

  % Parse input arguments
  parser.parse(varargin{:});

  % Store the results
  opts = parser.Results;

  % User feedback
  fprintf('Adding ([\b1]\b) [\b%s]\b objective... \n', opts.description);

  % Verify data type
  expression = ConstantNode(0) + expression;

  % Check number of objective objects
  if obj.numberOfObjectives >= 1
    error('Multi-objective problem formulations are not supported.');
  end % if

  % Store objective function in problem structure
  obj.objective(end+1) = Objective(expression, opts.description);
end % addObjective
