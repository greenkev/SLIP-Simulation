function export(obj)
%EXPORT Export optimization functions for IPOPT.
%
% Copyright 2013-2015 Mikhail S. Jones

	% User feedback
	fprintf('Exporting IPOPT functions... \n');

	% Number of variables, constraints, and objectives
	nVars = obj.nlp.numberOfVariables;
	nCons = obj.nlp.numberOfConstraints;
	nObjs = obj.nlp.numberOfObjectives;

	% Write objective function
	gen = MatlabFunctionGenerator({'var'}, {'f'}, obj.path, 'ipoptObjective');
	gen.writeHeader;
	f = vertcat(obj.nlp.objective.expression);
	gen.writeExpression(f, 'f');
	gen.writeFooter;

	% Write objective gradient function
	gen = MatlabFunctionGenerator({'var'}, {'g'}, obj.path, 'ipoptGradient');
	gen.writeHeader;
	[ig, jg, sg] = f.jacobian;
	gen.writeIndex(ig, 'ig');
	gen.writeIndex(jg, 'jg');
	gen.writeExpression(sg, 'sg');
	fprintf(gen.fid, '\tg = sparse(ig, jg, sg, %d, %d);\n\n', nObjs, nVars);
	gen.writeFooter;

	% Write constraint function
	gen = MatlabFunctionGenerator({'var'}, {'c'}, obj.path, 'ipoptConstraints');
	gen.writeHeader;
	if ~isempty(obj.nlp.constraint)
		c = vertcat(obj.nlp.constraint.expression);
	else
		c = ConstantNode.empty;
	end % if
	gen.writeExpression(c, 'c');
	gen.writeFooter;

	% Write constraint jacobian function
	gen = MatlabFunctionGenerator({'var'}, {'J'}, obj.path, 'ipoptJacobian');
	gen.writeHeader;
	if ~isempty(obj.nlp.constraint)
		[iJ, jJ, sJ] = c.jacobian;
	else
		iJ = {}; jJ = {}; sJ = ConstantNode.empty;
	end % if
	gen.writeIndex(iJ, 'iJ');
	gen.writeIndex(jJ, 'jJ');
	gen.writeExpression(sJ, 'sJ');
	fprintf(gen.fid, '\tJ = sparse(iJ, jJ, sJ, %d, %d);\n\n', nCons, nVars);
	gen.writeFooter;

	% Write constraint jacobian structure function
	gen = MatlabFunctionGenerator({'var'}, {'J'}, obj.path, 'ipoptJacobianStructure');
	gen.writeHeader;
	gen.writeIndex(iJ, 'iJ');
	gen.writeIndex(jJ, 'jJ');
	fprintf(gen.fid, '\tsJ = 1 + zeros(1,%d);\n', sum([sJ.length]));
	fprintf(gen.fid, '\tJ = sparse(iJ, jJ, sJ, %d, %d);\n\n', nCons, nVars);
	gen.writeFooter;
end % export
