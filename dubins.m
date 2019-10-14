clc;
R=1;% 最小曲率半径
x0=8;
y0=10;
phi0=90;% 初始角度
x=x0+R*cos((phi0+90)/57.3)   %逆时针圆圆心--起始圆
y=y0+R*sin((phi0+90)/57.3)
plot([x],[y],'*')
hold on

x1=x0+R*cos((phi0-90)/57.3)  %顺时针圆圆心--起始圆
y1=y0+R*sin((phi0-90)/57.3)
plot([x1],[y1],'*')

a0=0;
b0=9;
theta0=125;
a=a0+R*cos((theta0+90)/57.3)    %逆时针圆圆心--终止圆
b=b0+R*sin((theta0+90)/57.3)
plot([a],[b],'*')

a1=a0+R*cos((theta0-90)/57.3)    %顺时针圆圆心--终止圆
b1=b0+R*sin((theta0-90)/57.3)
plot([a1],[b1],'*')




drawCircle(x,y,R);
drawCircle(x1,y1,R);
drawCircle(a,b,R);
drawCircle(a1,b1,R)
quiver(x0,y0,R*cos(phi0/57.3),R*sin(phi0/57.3))
quiver(a0,b0,R*cos(theta0/57.3),R*sin(theta0/57.3))

%圆心距
L1=sqrt((x-a)*(x-a)+(y-b)*(y-b))
L2=sqrt((x-a1)*(x-a1)+(y-b1)*(y-b1))
L3=sqrt((x1-a)*(x1-a)+(y1-b)*(y1-b))
L4=sqrt((x1-a1)*(x1-a1)+(y1-b1)*(y1-b1))


alpa=-pi/2+atan(2*R/L2);
F=[a1;b1]+[cos(alpa) -sin(alpa);sin(alpa) cos(alpa)]*[x-a1;y-b1]*R/L2;
xb=F(1)       %切点坐标
yb=F(2)

I=[x;y]+[cos(alpa) -sin(alpa);sin(alpa) cos(alpa)]*[a1-x;b1-y]*R/L2;
xa=I(1)       %起点坐标
ya=I(2)

qiexian=sqrt((xa-xb)*(xa-xb)+(ya-yb)*(ya-yb))   %切线长度

k=(yb-ya)/(xb-xa)        %画切线
%u=xa:0.01:xb
u=xb:0.01:xa
g=k*(u-xa)+ya
plot(u,g)
axis equal

d1=sqrt((x0-xa)*(x0-xa)+(y0-ya)*(y0-ya))        %求弧长
beta1=2*asin(d1/2/R)
huchang1=beta1*R

d2=sqrt((a0-xb)*(a0-xb)+(b0-yb)*(b0-yb))        %求弧长
beta2=2*asin(d2/2/R)
huchang2=beta2*R


zongchang=qiexian+huchang1+huchang2             %dubins曲线长度
