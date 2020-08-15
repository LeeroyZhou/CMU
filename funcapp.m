function [Time, Angle, Mmax]=funcapp(a,t1,t3,UIAxes)
inf=10000000;
D1=60; D2=15; l=15; m=6000;
g=9.8; Tmax=20000*g;
%a=0.5; t1=5; t2=20; t3=4;%此时t为每段的时间间隔
xa1=a*t1*t1/2; xa3=D1; xa4=D1+D2; xa2=xa3-0.5*a*t3*(2*t1-t3);
t2=(xa2-xa1)/(a*t1); t4=(xa4-xa3)/(a*(t1-t3)); %xai为第i段结束后吊车的位移
t2=t2+t1; t3=t2+t3; t4=t3+t4;%此时t为每段结束的时刻
t=cell(4,1); theta=cell(4,1); x=cell(4,1); y=cell(4,1); %时间，角度，横纵坐标
va=cell(4,1); va{2}=a*t1; va{4}=a*(t1+t2-t3);%吊车速度
v=cell(4,1); Tx=cell(4,1); Ty=cell(4,1); T=cell(4,1); %水平速度，拉力,
ax=cell(4,1); ay=cell(4,1);%水平竖直加速度
thetamax=0; Tm=0; %实际最大的角度，拉力

if t2<0 || (t3-t2)>=t1 || (t2-t1)<0.1 || t4>120
    Time=inf; Angle=inf; Tm=inf;
    return;
end

%第一段加速
dydt=@(t,y)[ y(2) ; (-a*y(2)*t*sin(y(1))+a*cos(y(1))-g*sin(y(1)))/l ];
options = odeset('RelTol',1e-5,'AbsTol',[1e-5 1e-5]);
[t{1},theta{1}] = ode45(dydt,[0:0.05:t1],[0 0],options);
x{1}=0.5*a*t{1}.^2-l*sin(theta{1}(:,1));
v{1}=a*t{1}-l*theta{1}(:,2).*cos(theta{1}(:,1));

%第二段匀速
dydt=@(t,y)[ y(2) ; (1/l)*(va{2}*y(2)*sin(y(1))-(va{2}+g)*sin(y(1))) ];
options = odeset('RelTol',1e-5,'AbsTol',[1e-5 1e-5]);
[t{2},theta{2}] = ode45(dydt,[t1:0.05:t2],[theta{1}(length(theta{1}(:,1)),1) theta{1}(length(theta{1}(:,2)),2)],options);
x{2}=xa1+a*t1*(t{2}-t1)-l*sin(theta{2}(:,1));
v{2}=a*t1-l*theta{2}(:,2).*cos(theta{2}(:,1));

%第三段减速
dydt=@(t,y)[ y(2) ; (-a*y(2)*(t1+t2-t)*sin(y(1))-a*cos(y(1))-g*sin(y(1)))/l ];
options = odeset('RelTol',1e-5,'AbsTol',[1e-5 1e-5]);
[t{3},theta{3}] = ode45(dydt,[t2:0.05:t3],[theta{2}(length(theta{2}(:,1)),1) theta{2}(length(theta{2}(:,2)),2)],options);
x{3}=xa2+a*t1*(t{3}-t2)-0.5*a*(t{3}-t2).^2-l*sin(theta{3}(:,1));
v{3}=a*(t1+t2-t{3})-l*theta{3}(:,2).*cos(theta{3}(:,1));

%第四段匀速
dydt=@(t,y)[ y(2) ; (1/l)*(va{4}*y(2)*sin(y(1))-(va{4}+g)*sin(y(1))) ];
options = odeset('RelTol',1e-5,'AbsTol',[1e-5 1e-5]);
[t{4},theta{4}] = ode45(dydt,[t3:0.05:t4],[theta{3}(length(theta{3}(:,1)),1) theta{3}(length(theta{3}(:,2)),2)],options);
x{4}=xa3+a*(t1+t2-t3)*(t{4}-t3)-l*sin(theta{4}(:,1));
v{4}=a*(t1+t2-t3)-l*theta{4}(:,2).*cos(theta{4}(:,1));
thetamax=max(theta{4}(:,1));

for i=1:4
    y{i}=l*cos(theta{i}(:,1));
    ax{i}=gradient(v{i},0.05);
    Tx{i}=m*ax{i};
    ay{i}=-1*(gradient(theta{i}(:,2),0.05).*sin(theta{i}(:,1)) + cos(theta{i}(:,1)).*theta{i}(:,2).^2);
    Ty{i}=m*(g-l*ay{i});
    T{i}=(Tx{i}.^2 + Ty{i}.^2).^0.5;
    Tm=max(Tm,max(T{i}));
    p=plot(UIAxes,t{i},theta{i}(:,1),'linewidth',1.5);
    hold(UIAxes,'on' )
end

E4 = 0.5*m*(v{4}(length(v{4}))^2 + (l*theta{4}(length(theta{4}(:,2)),2)*sin(theta{4}(length(theta{4}(:,1)),1)))^2);
vcx=(2*E4/m + 2*g*l*(1-cos(theta{4}(length(theta{4}(:,1)),1))))^0.5;
thetamax=max(thetamax,acos(1-E4/(m*g*l)));

vcx=max(vcx,max(v{4}));
if Tm>Tmax || vcx>0.5 %若拉力超限，最终速度超限
    Time=inf; Angle=inf;
    return;
end

Time=t4; Angle=thetamax; Mmax=m*Tmax/Tm;