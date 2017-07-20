figure
% left LIP, intact
disp('left LIP');
x = [-50:50];
% E_l = 1*ones(1,101)'*[10:0.5:60]; % uniform gain
E_l = 1*ones(1,101)'*(0.01*[10:0.5:60].^2); % quad gain

R_l = 1*[10:110]'*ones(1,101); % uniform gain


T_l = R_l+E_l;


Tc_l = T_l(51-25,51) % contralesional, left
Ti_l = T_l(51+25,51) % ipsilesional, right
fprintf('right/left choice center %0.3f\n',Ti_l/Tc_l);

T1c_l = T_l(51-25,51+25)
T1i_l = T_l(51+25,51+25)
fprintf('right/left choice right %0.3f\n',T1i_l/T1c_l);

subplot(1,2,1)
surface(x,x,T_l); shading flat; hold on;
plot3(zeros(1,101),x,T_l(:,51),'k')
plot3(x,zeros(1,101),T_l(51,:),'k')

plot3(0,-25,T_l(51-25,51),'ko')
plot3(0,25,T_l(51+25,51),'ko')

plot3(25,-25,T_l(51-25,51+25),'ko')
plot3(25,25,T_l(51+25,51+25),'ko')


% right LIP, injected hemi
disp('right LIP');
% E_r = 0.5*fliplr(ones(1,101)'*35*ones(1,101)); %[10:0.5:60]
% E_r = 1*fliplr(ones(1,101)'*[10:0.5:60]);
E_r = 1*fliplr(ones(1,101)'*(0.01*[10:0.5:60].^2));

R_r = 1*flipud( max(0, ([10:110] -0 ))'*ones(1,101));

T_r = R_r+E_r;

Tc_r = T_r(51-25,51)
Ti_r = T_r(51+25,51)
fprintf('left/right choice center %0.3f\n',Tc_r/Ti_r);

T1c_r = T_r(51-25,51+25)
T1i_r = T_r(51+25,51+25)
fprintf('left/right choice right %0.3f\n',T1c_r/T1i_r);

subplot(1,2,2)
surface(x,x,T_r); shading flat; hold on;
plot3(zeros(1,101),x,T_r(:,51),'k')
plot3(x,zeros(1,101),T_r(51,:),'k')

plot3(0,-25,T_r(51-25,51),'ko')
plot3(0,25,T_r(51+25,51),'ko')

plot3(25,-25,T_r(51-25,51+25),'ko')
plot3(25,25,T_r(51+25,51+25),'ko')



% summary across both hemi:
disp('summary across both hemi');
Tc = Tc_l + Tc_r
Ti = Ti_l + Ti_r
T1c = T1c_l + T1c_r
T1i = T1i_l + T1i_r


fprintf('right/left choice center %0.3f\n',Ti/Tc);
fprintf('right/left choice right %0.3f\n',T1i/T1c);




