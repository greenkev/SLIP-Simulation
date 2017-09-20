function f = dynamics(obj,in1,in2)
%DYNAMICS
%    F = DYNAMICS(IN1,IN2,GRAV,M_BODY,I_BODY,B_HIP,M_THIGH,R_THIGH,I_THIGH,B_ROT,M_ROT,K_LEG,B_LEG,M_TOE)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    20-Sep-2017 15:26:25

q4 = in1(4,:);
q5 = in1(5,:);
q6 = in1(6,:);
qdot4 = in2(4,:);
qdot6 = in2(6,:);
t2 = sin(q4);
t3 = cos(q4);
t4 = qdot4.^2;
f = [qdot4.*(obj.m_toe.*(qdot6.*t3.*2.0-q6.*qdot4.*t2.*2.0).*(1.0./2.0)-obj.m_thigh.*qdot4.*obj.r_thigh.*t2)+obj.m_toe.*qdot4.*qdot6.*t3;obj.grav.*obj.m_body+obj.grav.*obj.m_toe+obj.grav.*obj.m_thigh+obj.m_toe.*qdot4.*qdot6.*t2.*2.0+obj.m_toe.*q6.*t3.*t4+obj.m_thigh.*obj.r_thigh.*t3.*t4;0.0;obj.grav.*obj.m_toe.*q6.*t2+obj.grav.*obj.m_thigh.*obj.r_thigh.*t2+obj.m_toe.*q6.*qdot4.*qdot6.*2.0;obj.k_leg.*(q5.*2.0-q6.*2.0).*(1.0./2.0);-obj.k_leg.*q5+obj.k_leg.*q6-obj.grav.*obj.m_toe.*t3-obj.m_toe.*q6.*t4];
