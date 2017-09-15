% Hessian*vector multiplication function for Fmincon.
% This uses that a Hessian*vector product is just the directional
% derivative of the gradient of the Lagrangian in the given direction.
function val = fmincon_hessMult(x, lambda, vec)
	% Step length
	ssize = eps^2;

	% The length of the vector we are differentiating against.
	vec_len = norm(vec);

	% Sometimes Fmincon gives us vec == 0 (particularly on small problems).
	% In this case, ssize/vec_len divides by zero, so catch and avoid that case.
	if vec_len == 0
		val = zeros(numel(x), 1);
		return
	end

	% The step vector -- same direction as vec, but it has length ssize
	step = vec * (ssize/vec_len);

	% Complex step differentiation!
	val = imag(lagr_grad(x + step * i, lambda))*(vec_len/ssize);
end

% Computes the gradient of the Lagrangian. Used for the Hessian Multiply function
function ghess = lagr_grad(x, lambda)
	%ghess = this.eval_sparse(this.objjac, x)                     + ...
	%	this.eval_sparse(this.cjac,   x) * lambda.ineqnonlin + ...
	%	this.eval_sparse(this.ceqjac, x) * lambda.eqnonlin;

	[~,gobj]      = fminconObj(x);
	[~,~,gc,gceq] = fminconNonlcon(x);
	ghess = gobj(:) + gc * lambda.ineqnonlin(:) + gceq * lambda.eqnonlin(:);
end
