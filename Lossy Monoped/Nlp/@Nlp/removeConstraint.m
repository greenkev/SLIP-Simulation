function removeConstraint(obj, description)
%REMOVECONSTRAINT Remove a constraint from the NLP problem.
%
% Syntax:
%   obj.removeConstraint(description)
%
% Required Input Arguments:
%   description - (CHAR) Description for identification.

% Copyright 2016 Mikhail S. Jones

  constraint = Constraint.empty;
  
  for i = 1:numel(obj.constraint)
    if ~strcmp(description, obj.constraint(i).description)
      constraint = [constraint, obj.constraint(i)];
    else
      % User feedback
      fprintf('Removing ([\b%d]\b) [\b%s]\b constraints... \n', ...
        sum(sum([obj.constraint(i).expression.length])), obj.constraint(i).description);
    end % if
  end % for
  
  obj.constraint = constraint;
end % removeConstraint
