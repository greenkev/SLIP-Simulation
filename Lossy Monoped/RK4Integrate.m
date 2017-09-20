function [t_out,y_out,u_out] = RK4Integrate(dyn,tspan,y0,options)
%RK4INTEGRATE This is a fixed timestep RK4 integrator with zero order hold
%controller function
%

while t < tstop
    
    for i = 1:ratio
        X1 = X;
        dX1 = biped_dynamics(X1, u, ext0, robot, terrain);
        
        X2 = rs_add(X1, rs_smul(dX1, Ts/2));
        dX2 = biped_dynamics(X2, u, ext0, robot, terrain);
        
        X3 = rs_add(X1, rs_smul(dX2, Ts/2));
        dX3 = biped_dynamics(X3, u, ext0, robot, terrain);
        
        X4 = rs_add(X1, rs_smul(dX3, Ts));
        dX4 = biped_dynamics(X4, u, ext0, robot, terrain);
        
        X = rs_add(X1, rs_smul(rs_add(rs_add(dX1, rs_smul(dX2, 2)), rs_add(rs_smul(dX3, 2), dX4)), Ts/6));
        t = t + Ts;
    end
    
    [u, cstate] = controller_step(X_delay, cstate, cparams, Ts * ratio);
    
    f = 1e-2;
    noiseval = (1 - f) * noiseval + f * noise * randn(4, 1);
    
    u.right.l_eq     = u.right.l_eq + noiseval(1);
    u.right.theta_eq = u.right.theta_eq + noiseval(2);
    u.left.l_eq      = u.left.l_eq + noiseval(3);
    u.left.theta_eq  = u.left.theta_eq + noiseval(4);
    
    X_delay = X;
    
    % Stop if crashed
    if X.body.y < min(terrain.height)
        break
    end
end


end

