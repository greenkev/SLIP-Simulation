function plot(this)
%PLOT Plot the optimization solution and objective function.
%
% Syntax:
%   obj.plot
%
% Description:
%   Plots objective function, initial point and solution if found. Only
%   supports one and two dimensional problems, resulting in two and three
%   dimensional plots.
%
% Copyright 2013-2014 Mikhail S. Jones

	% Error check for empty variable structure
	if isempty(this.variable)
		error('coalesce:optimize:Nlp:plot', ...
			'Problem can not be plotted, no declared variables.');
	end % if

	% Check for supported problem sizes
	if this.numberOfVariables > 2
		error('coalesce:optimize:Nlp:plot', ...
			'Problems greater than 2 dimensions can not be plotted.');
	end % if

	% Create function handle (much faster than matlabFunction but same idea)
	str = char(this.objective.expression);
	str = regexprep(str, 'var\(([0-9:]+)\)', 'var(:,$1)');
  str = ['@(var)' str];
  objFcn = str2func(str);

	% Initialize the figure and set defaults
	figure('Name', this.options.name);
	hold on;

	% Plot objective function versus design variables
	switch this.numberOfVariables
	case 1
		% Domain of variables
		domain = [this.variableLowerBound this.variableUpperBound];

		% Display two dimensional line plot
		ezplot(objFcn, domain, 100);
		view(2);
		hSol = plot(this.solution, objFcn(this.solution), 'r.', ...
			'MarkerSize', 20);
		hInit = plot(this.initialGuess, objFcn(this.initialGuess), 'k.', ...
			'MarkerSize', 20);

	case 2
		% Domain of variables
		domain([1,3]) = this.variableLowerBound;
		domain([2,4]) = this.variableUpperBound;

		% Display three dimensional mesh plot
		ezmeshc(@(var1, var2) objFcn([var1 var2]), domain, 100);
		view(3);
		hSol = plot3(this.solution(1), this.solution(2), objFcn(this.solution), 'r.', ...
			'MarkerSize', 20);
		hInit = plot3(this.initialGuess(1), this.initialGuess(2), objFcn(this.initialGuess), 'k.', ...
			'MarkerSize', 20);
	end % switch

	% Axes properties
	grid on; box on;
	legend([hSol, hInit], 'Solution', 'Initial Guess');
	title(this.options.name);

	% Update figure windows
	drawnow;
end % plot
