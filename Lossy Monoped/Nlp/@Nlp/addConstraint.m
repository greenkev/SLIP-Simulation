function addConstraint(obj, lowerBound, expression, upperBound, varargin)
%ADDCONSTRAINT Add a constraint to the NLP problem.
%
% Syntax:
%   obj.addConstraint(lowerBound, expression, upperBound)
%
% Required Input Arguments:
%   lowerBound - (DOUBLE) Design variable lower bounds.
%   expression - (EXPRESSIONNODE) Symbolic constraint expression.
%   upperBound - (DOUBLE) Design variable upper bounds.
%
% Optional Input Arguments:
%   description - (CHAR) Description for identification.

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
  fprintf('Adding ([\b%d]\b) [\b%s]\b constraints... \n', ...
    sum(sum([expression.length])), opts.description);

  % ANDY ADDED THIS
  if numel(lowerBound) == 1
      lowerBound = repmat(lowerBound,numel(expression),1);
      upperBound = repmat(upperBound,numel(expression),1);
  end

  for i = 1:numel(expression)
    % Append object array with more constraints
    obj.constraint(end+1) = Constraint(expression(i), ...
      lowerBound(i), upperBound(i), opts.description); % ANDY: added (i) to upper and lower bounds
  end % for
end % addConstraint
