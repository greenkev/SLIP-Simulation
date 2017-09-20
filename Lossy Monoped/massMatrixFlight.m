function f = massMatrix(obj,in1)
%MASSMATRIX
%    F = MASSMATRIX(IN1,GRAV,M_BODY,I_BODY,B_HIP,M_THIGH,R_THIGH,I_THIGH,B_ROT,M_ROT,K_LEG,B_LEG,M_TOE)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    20-Sep-2017 15:26:25

q4 = in1(4,:);
q6 = in1(6,:);
t2 = cos(q4);
t3 = obj.m_body+obj.m_toe+obj.m_thigh;
t4 = sin(q4);
t5 = obj.m_toe.*q6.*t2;
t6 = obj.m_thigh.*obj.r_thigh.*t2;
t7 = t5+t6;
t8 = obj.m_toe.*q6.*t4;
t9 = obj.m_thigh.*obj.r_thigh.*t4;
t10 = t8+t9;
t11 = obj.m_toe.*t4;
f = reshape([t3,0.0,0.0,t7,0.0,t11,0.0,t3,0.0,t10,0.0,-obj.m_toe.*t2,0.0,0.0,obj.I_body,0.0,0.0,0.0,t7,t10,0.0,obj.I_thigh+obj.m_toe.*q6.^2+obj.m_thigh.*obj.r_thigh.^2,0.0,0.0,0.0,0.0,0.0,0.0,obj.m_rot,0.0,t11,-obj.m_toe.*t2,0.0,0.0,0.0,obj.m_toe],[6,6]);
