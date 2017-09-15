classdef InteractiveAnalysis < InteractiveWindow
    
    properties
        s
        q
        qdot
        lclick
        rclick
        activejoint
        clickpoint
        
        dt = 0.001
    end
    
    methods
        function o = InteractiveAnalysis()
            o.reset();
        end
        
        function reset(o)
            o.s = CassieSystem;
            o.q = [0.2,-0.4, 0,0,0,0]';
%             o.s = InLineSerialSystem;
%             o.q = [0.2,-0.4, 0,0,0,0]';
%             o.s = PantographSystem;
%             o.q = [-0.2,0.4, 0,0,0,0]';
            o.s.g = 0;
            o.hax.XLim = [-0.75,0.75];
            o.hax.YLim = [-1.25,0.25];
            o.lclick = false;
            o.activejoint = nan;
            o.draw();
        end
        
        function q = ik(o,p,joint)
            dof = [1,2];
            q = o.q;
            if isnan(joint), return; end
            for i = 1:10
            J = o.s.jacobian(q);
            J = J((2*joint-1):(2*joint),dof);
            x = o.s.eval(q);
            x = x(:,joint);
            e = p-x;
            q(dof) = q(dof) + J' / (J*J' + 0.05*eye(2)) * e; % damped-least-squares
            end
        end
        
        function q = applyForce(o,F,joint)
            dof = [3,4]; % dof to remove
            q = o.q;
            if isnan(joint), return; end
            niter = 10;
            for i = 1:niter
            J = o.s.jacobian(q);
            J = J((2*joint-1):(2*joint),dof);
            K = o.s.stiffnessMatrix(q);
            K = K(dof,dof);
            Q = J'*F; % generalized force on joints
            qspring = K\Q * i/niter;
            q(dof) = qspring;
            end
        end
        
        function mouseDown(o,p,type)
            switch type
                case 'normal'
                    o.lclick = true;
                    o.ik(p,o.activejoint);
                case 'alt'
                    o.rclick = true;
            end
            o.clickpoint = p;
        end
        
        function mouseUp(o,~,~)
            o.lclick = false;
            o.rclick = false;
            o.q = o.applyForce([0;0],o.activejoint);
            o.draw();
        end
        
        function mouseMove(o,p,type)
            if o.lclick
                p(1) = 0;
                o.q = o.ik(p,o.activejoint);
                o.draw();
            elseif o.rclick
                p(1) = 0;
                F = (p - o.clickpoint) * 10000;
                o.q = o.applyForce(F,o.activejoint);
                o.draw();
            else % find nearest joint
                x = o.s.eval(o.q);
                d = sqrt(sum((x-p).^2));
                [dmin,index] = min(d);
                if dmin < 0.1
                    o.activejoint = index;
                else
                    o.activejoint = nan;
                end
                o.draw();
            end
        end
        
        function keyDown(o,char,key,mod)
            switch key
                case 'escape'
                    o.reset()
            end
        end
        
        function draw(o)
            o.clear();
            
            ang = linspace(0,2*pi,50);
            dx = [cos(ang);sin(ang)];

            q0 = o.q;
            joints = o.s.eval(q0);
            
            M = o.s.massMatrix(q0);
            K = o.s.stiffnessMatrix(q0);
            J = o.s.jacobian(q0);
            
            n_joints = size(J,1)/2;
            n_segments = n_joints - 1;
            N = 10;
            
            line(joints(1,:),joints(2,:),'color','k','marker','.','linewidth',4,'markersize',10)
            if ~isnan(o.activejoint)
                line(joints(1,o.activejoint),joints(2,o.activejoint),'color','g','marker','o','markersize',20)
            end
            
            for i = 1:N
                n1 = floor((i-1)/(N-1) * n_segments) + 1;
                n1 = min(max(n1,0),n_joints-1);
                n2 = n1 + 1;
                j1 = J((2*n1-1):(2*n1),:);
                j2 = J((2*n2-1):(2*n2),:);
                x1 = joints(:,n1);
                x2 = joints(:,n2);
                bias = (i-1)/(N-1)*n_segments - (n1-1);
                j = (1-bias)*j1 + (bias)*j2;
                x = (1-bias)*x1 + (bias)*x2;
                
                % K*dx = J' * f
                C_ef = j * (pinv(K) * j'); % this is correct
                % M * dqdot = J' * I
                % dqdot = M \ J' * I
                % J * dqdot = J * M \ J' * I
                % dxdot = J * M \ J' * I
                M_ef = j * (M \ j');
                f1 = M_ef \ dx * 0.01;
                f2 = C_ef * dx * 1000;
%                 f3 = j(:,1:2)*j(:,1:2)' * dx * 0.2;
                line(x(1)+f1(1,:),x(2)+f1(2,:),'color',[1,0,0,0.9],'linewidth',2)
                line(x(1)+f2(1,:),x(2)+f2(2,:),'color',[0,0,1,0.5],'linewidth',2,'linestyle',':')
%                 line(x(1)+f3(1,:),x(2)+f3(2,:),'color','k','linewidth',1,'linestyle','-')
            end
            
            line(joints(1,:),joints(2,:),'color','k','linestyle','none','marker','.','markersize',20)

            drawnow
            
        end
    end
    
end

