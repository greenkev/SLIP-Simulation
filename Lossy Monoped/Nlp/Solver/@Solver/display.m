function display(obj)
%DISPLAY Display design variable solution solution.
%
% Syntax:
%		obj
%   obj.display
%
% Description:
%   Displays all design variable solutions along with name and id.
%
% Copyright 2013-2015 Mikhail S. Jones

	% Construct divider line strings
	majorDivider = [repmat('=', 1, 75), '\n'];
	minorDivider = [repmat('-', 1, 75), '\n'];

	% Display solution summary header
	fprintf('\n');
	fprintf(majorDivider);
	fprintf([repmat(' ', 1, 30) '[\bSOLVER SUMMARY]\b \n']);
	fprintf(majorDivider);
	fprintf('* Solver: [\b%s]\b \n\n', class(obj));

	% Display solution summary
	for i = 1:numel(obj.nlp.variable)
		fprintf('[\b%s]\b \n', upper(obj.nlp.variable(i).description));
		fprintf(minorDivider);

		% Display variables within set
		for j = 1:obj.nlp.variable(i).length
			fprintf('%-12.12s %12.12s = [\b%.4e]\b \n', ...
				['  ' num2str(j) ')'], ...
				char(obj.nlp.variable(i)), ... % TODO
				obj.nlp.variable(i).solution(j));
		end % for
		fprintf('\n');
	end % for

	% Display solution summary footer
	fprintf(majorDivider);
	fprintf('\n');
end % display
