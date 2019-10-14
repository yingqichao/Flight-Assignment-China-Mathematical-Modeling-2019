function dist = distFunc(horizontalDistance,verticalDistance,originalDistance)
    % 用螺旋加直线来模拟水平与垂直方向的改变，并且不考虑水平与垂直方向改变需要转的长度
    R = 200;
    theta1 = 7/360*2*pi; % 直线下降
    theta2 = 11/360*2*pi; % 螺旋下降
    if(verticalDistance-horizontalDistance*tan(theta1)<0)
        %L*tan(theta1)
        dist = originalDistance;
        return;
    end
    C = (verticalDistance-horizontalDistance*tan(theta1))/(2*pi*R*tan(theta2));
    h1 = horizontalDistance/cos(theta1); % 直线长度
    h2 = C*2*pi*R/cos(theta2); % 螺旋长度
    dist = h1+h2;
end