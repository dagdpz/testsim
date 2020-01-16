% function testsim_MI_coordination

MIS = 0.01:0.01:1;
MIT = 0.01:0.01:1;


n = length(MIT);

m = 1;
for s = 1:n,
    for t = 1:n,
        CoordType(s,t) = atan(MIS(s)/MIT(t))*180/pi;
        CoordStrength(s,t) = sqrt(MIS(s)^2 + MIT(t)^2);
        x=min(CoordType(s,t),90-CoordType(s,t))/180*pi; % rad
        normCoordStrength(s,t) = CoordStrength(s,t)/sqrt(1+tan(x)^2);
        normCoordStrength_simple(s,t) = max(MIS(s),MIT(t));
        MI.MIS(m) = MIS(s);
        MI.MIT(m) = MIT(t);
        m = m + 1;
        
    end
end

figure('Color',[1 1 1])
subplot(2,1,1)
plot(reshape(CoordType,1,n^2),reshape(CoordStrength,1,n^2),'k.','MarkerSize',0.5);
xlabel('Coordination type');
ylabel('Coordination strength');

subplot(2,1,2)
plot(reshape(CoordType,1,n^2),reshape(normCoordStrength,1,n^2),'k.','MarkerSize',0.5); hold on;
% plot(reshape(CoordType,1,n^2),reshape(normCoordStrength_simple,1,n^2),'ro');
xlabel('Coordination type');
ylabel('Normalized coordination strength');

figure('Color',[1 1 1])
plot(MI.MIS,MI.MIT,'k.','MarkerSize',0.5);
xlabel('MIS');
ylabel('MIT');
axis equal
axis square


