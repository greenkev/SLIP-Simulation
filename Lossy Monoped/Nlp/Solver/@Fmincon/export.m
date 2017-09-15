function export(obj)
%EXPORT Export optimization functions for MATLAB FMINCON.
%
% Copyright 2013-2015 Mikhail S. Jones

	% User feedback
	fprintf('Exporting FMINCON functions... \n');

	% Number of variables, constraints, and objectives
	nVars = obj.nlp.numberOfVariables;
	nCons = obj.nlp.numberOfConstraints;
	nObjs = obj.nlp.numberOfObjectives;

	% Split equality and inequality constraints
	equality = [];
	for k = numel(obj.nlp.constraint):-1:1
		equality(k) = all(obj.nlp.constraint(k).lowerBound == obj.nlp.constraint(k).upperBound);
	end % for
	equality = logical(equality);

	% Write user function
	gen = MatlabFunctionGenerator({}, {'A', 'b', 'Aeq', 'beq'}, 'auto', 'fminconUser');
	gen.writeHeader;
	gen.writeExpression(ConstantNode.empty, 'A');
	gen.writeIndex({}, 'b');
	gen.writeExpression(ConstantNode.empty, 'Aeq');
	gen.writeIndex({}, 'beq');
	gen.writeFooter;

	% Write objective function
	gen = MatlabFunctionGenerator({'var'}, {'f', 'g'}, 'auto', 'fminconObj');
	gen.writeHeader;
	f = vertcat(obj.nlp.objective.expression);
	gen.writeExpression(f, 'f');
	[ig, jg, sg] = f.jacobian;
	gen.writeIndex(ig, 'ig');
	gen.writeIndex(jg, 'jg');
	gen.writeExpression(sg, 'sg');
	fprintf(gen.fid, '\tg = sparse(ig, jg, sg, %d, %d);\n\n', nObjs, nVars);
	gen.writeFooter;

	% Write nonlinear constraint function
	gen = MatlabFunctionGenerator({'var'}, {'c', 'ceq', 'G', 'Geq'}, 'auto', 'fminconNonlcon');
	gen.writeHeader;
	c = ConstantNode.empty;
	for k = find(~equality)
		if obj.nlp.constraint(k).lowerBound(1) ~= -Inf
			c(end+1) = obj.nlp.constraint(k).lowerBound(1) - obj.nlp.constraint(k).expression;
		end % if
	end % for
	for k = find(~equality)
		if obj.nlp.constraint(k).upperBound(1) ~= Inf
			c(end+1) = obj.nlp.constraint(k).expression - obj.nlp.constraint(k).upperBound(1);
		end % if
	end % for
	gen.writeExpression(c, 'c');
	ceq = ConstantNode.empty;
	for k = find(equality)
		ceq(end+1) = obj.nlp.constraint(k).expression - obj.nlp.constraint(k).lowerBound(1);
	end % for
	gen.writeExpression(ceq, 'ceq');
	fprintf(gen.fid, '\tif nargout > 2\n');
	[jG, iG, sG] = c.jacobian;
	gen.writeIndex(iG, 'iG');
	gen.writeIndex(jG, 'jG');
	gen.writeExpression(sG, 'sG');
	fprintf(gen.fid, '\tG = sparse(iG, jG, sG, %d, %d);\n\n', nVars, sum([c.length]));
	[jGeq, iGeq, sGeq] = ceq.jacobian;
	gen.writeIndex(iGeq, 'iGeq');
	gen.writeIndex(jGeq, 'jGeq');
	gen.writeExpression(sGeq, 'sGeq');
	fprintf(gen.fid, '\tGeq = sparse(iGeq, jGeq, sGeq, %d, %d);\n\n', nVars, sum([ceq.length]));
	fprintf(gen.fid, '\tend %% if\n');
	gen.writeFooter;
end % export
