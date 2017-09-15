function display(this)
%DISPLAY Display problem formulation summary.
%
% Syntax:
%   obj
%   obj.display
%
% Description:
%   Display problem formulation summary in table form.
%
% Copyright 2013-2014 Mikhail S. Jones

	% Don't display arrays of objects
	if numel(this) > 1; return; end % if

	% Construct divider line strings
	majorDivider = [repmat('=', 1, 75), '\n'];
	minorDivider = [repmat('-', 1, 75), '\n'];

	% Display problem summary header
	fprintf('\n');
	fprintf(majorDivider);
	fprintf([repmat(' ', 1, 30) '[\bPROBLEM SUMMARY]\b \n']);
	fprintf(majorDivider);
	fprintf('* Name: [\b%s]\b \n\n', this.options.name);

	% Display variable summary
	nVars = this.numberOfVariables;
	nSets = numel(this.variable);
	fprintf('[\bVARIABLES]\b \n');
	fprintf(minorDivider);
	fprintf('* [\b%d]\b Design variable(s) in [\b%d]\b set(s)\n', nVars, nSets);
	for i = 1:nSets
		fprintf('\t* [\b%d]\b Variable(s) in [\b%s]\b set\n', ...
			this.variable(i).length, ...
			this.variable(i).description);
	end % for
	fprintf('\n');

	% Display objectives summary
	nSets = numel(this.objective);
	fprintf('[\bOBJECTIVES]\b \n');
	fprintf(minorDivider);
	fprintf('* [\b%d]\b Objective(s)\n', nSets);
	fprintf('\n');

	% Display constraints summary
	nCons = this.numberOfConstraints;
	nSets = numel(this.constraint);
	fprintf('[\bCONSTRAINTS]\b \n');
	fprintf(minorDivider);
	fprintf('* [\b%d]\b Constraint(s) in [\b%d]\b set(s)\n', nCons, nSets);
	for i = 1:nSets
		fprintf('\t* [\b%d]\b Constraint(s) in [\b%s]\b set\n', ...
			this.constraint(i).expression.length, ...
			this.constraint(i).description);
	end % for

	% Display problem summary footer
	fprintf(majorDivider);
	fprintf('\n');
end % display
