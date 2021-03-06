% Compute Hessian

% sigma = SymVariable('sigma', 1);
% lambda = SymVariable('lambda', nCons);

% for iter = 1:numel(this.g.s)
% 	i = this.nlp.objective.jacobian.i{iter};
% 	j = this.nlp.objective.jacobian.j{iter};
% 	s = this.nlp.objective.jacobian.s{iter};
% 	tmp = jacobian(sigma*s, var);
% 	for iter = 1:numel(tmp.s)
% 		tmp.i{iter} = j;
% 	end % for
% 	tmp.m = nVars;
% end % for
% H{1} = tmp;

% nCon = 0;
% for iCon = 1:numel(this.nlp.constraint)
% 	for iter = 1:numel(this.nlp.constraint(iCon).jacobian.s)
% 		i = nCon + this.nlp.constraint(iCon).jacobian.i{iter};
% 		j = this.nlp.constraint(iCon).jacobian.j{iter};
% 		s = this.nlp.constraint(iCon).jacobian.s{iter};
% 		tmp = jacobian(lambda(:,:,i)*s, var);
% 		for iter = 1:numel(tmp.s)
% 			tmp.i{iter} = j;
% 		end % for
% 		tmp.m = nVars;
% 		H{iCon} = tmp;
% 	end % for
% 	nCon = nCon + this.nlp.constraint(iCon).count;
% end % for




% function writeIpoptHessian
% %WRITEIPOPTHESSIAN
%
% 	% Open new file to write without automatic flushing (W vs w)
% 	fid = fopen('auto/ipoptHessian.m', 'W');
%
% 	% Write file header
% 	fprintf(fid, 'function H = ipoptHessian(var, sigma, lambda)\n');
% 	fprintf(fid, '%%IPOPTHESSIAN\n');
% 	fprintf(fid, '%%\n');
% 	fprintf(fid, '%% Auto-generated by COALESCE package %s at %s\n', ...
% 		this.nlp.version, datestr(now));
% 	fprintf(fid, '%%\n');
% 	fprintf(fid, '%% Copyright 2013-2014 Mikhail S. Jones\n');
% 	fprintf(fid, '\n');
%
% 	% Loop through and assign parameter values
% 	fprintf(fid, '\t%% Parameters\n');
% 	for i = 1:numel(this.nlp.parameter)
% 		fprintf(fid, '\t%s = [%s]; %% %s\n', ...
% 			matlab(this.nlp.parameter(i).expression), ...
% 			sprintf('%0.15g; ', [this.nlp.parameter(i).value]), ...
% 				this.nlp.parameter(i).description);
% 	end % for
% 	fprintf(fid, '\n');
%
% 	% Write Hessian
% 	fprintf(fid, '\t%% Hessian\n');
% 	if isempty(this.H)
% 		fprintf(fid, '\tH = [];\n\n');
% 	else
% 		fprintf(fid, '\tH = sparse(%d, %d);\n\n', this.H{1}.m, this.H{1}.n);
% 		for i = 1:numel(this.H)
% 			writeMatlabIndex(fid, this.H{i}.i, ['iH' num2str(i)]);
% 			writeMatlabIndex(fid, this.H{i}.j, ['jH' num2str(i)]);
% 			writeMatlabExpression(fid, this.H{i}.s, ['sH' num2str(i)]);
% 			fprintf(fid, '\tH = H + tril(sparse(iH%d, jH%d, sH%d, %d, %d));\n\n', i, i, i, this.H{i}.m, this.H{i}.n);
% 		end % for
% 	end % if
%
% 	% Write function end and close file
% 	fprintf(fid, 'end %% ipoptHessian');
% 	fclose(fid);
% end % writeIpoptHessian
%
% function writeIpoptHessianStructure
% %WRITEIPOPTHESSIANSTRUCTURE
%
% 	% Open new file to write without automatic flushing (W vs w)
% 	fid = fopen('auto/ipoptHessianStructure.m', 'W');
%
% 	% Write file header
% 	fprintf(fid, 'function H = ipoptHessianStructure\n');
% 	fprintf(fid, '%%IPOPTHESSIANSTRUCTURE\n');
% 	fprintf(fid, '%%\n');
% 	fprintf(fid, '%% Auto-generated by COALESCE package %s at %s\n', ...
% 		this.nlp.version, datestr(now));
% 	fprintf(fid, '%%\n');
% 	fprintf(fid, '%% Copyright 2013-2014 Mikhail S. Jones\n');
% 	fprintf(fid, '\n');
%
% 	% Loop through and assign parameter values
% 	fprintf(fid, '\t%% Parameters\n');
% 	for i = 1:numel(this.nlp.parameter)
% 		fprintf(fid, '\t%s = [%s]; %% %s\n', ...
% 			matlab(this.nlp.parameter(i).expression), ...
% 			sprintf('%0.15g; ', [this.nlp.parameter(i).value]), ...
% 				this.nlp.parameter(i).description);
% 	end % for
% 	fprintf(fid, '\n');
%
% 	% Write objective gradients
% 	fprintf(fid, '\t%% Hessian Structure\n');
% 	if isempty(this.H)
% 		fprintf(fid, '\tH = [];\n\n');
% 	else
% 		fprintf(fid, '\tH = sparse(%d, %d);\n\n', this.H{1}.m, this.H{1}.n);
% 		for i = 1:numel(this.H)
% 			writeMatlabIndex(fid, this.H{i}.i, ['iH' num2str(i)]);
% 			writeMatlabIndex(fid, this.H{i}.j, ['jH' num2str(i)]);
% 			fprintf(fid, '\tsH%d = 1+zeros(1,%d);\n', i, nnz(this.H{i}));
% 			fprintf(fid, '\tH = H + tril(sparse(iH%d, jH%d, sH%d, %d, %d));\n\n', i, i, i, this.H{i}.m, this.H{i}.n);
% 		end % for
% 	end % if
%
% 	% Write function end and close file
% 	fprintf(fid, 'end %% ipoptHessianStructure');
% 	fclose(fid);
% end % writeIpoptHessianStructure
