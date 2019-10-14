clear all;
excel=xlsread('1.xlsx');
%%%%%%Setting%%%%%%%%
VerticalAdjustVertical = 25;
VerticalAdjustHorizontal = 15;
HorizontalAdjustVertical = 20;
HorizontalAdjustHorizontal = 25;
theta = 30;
delta = 0.001;
IndexOfFunc = 5;
IsVerticalAdjustment = 1;IsHorizontalAdjustment = 0;

%%%
% For A-star
SORT_ORDER = 1;
%%%%%%%%%%%%%%%%%%%%%
% 检查哪些边是可以走的，对于水平修正的点，需要满足delta*distance<=min(vertical/horizontal)
s = size(excel);rows = s(1);
distance = zeros(rows-1,rows);
sumRow = zeros(rows-1,2);xVerAdj = [];yVerAdj = [];zVerAdj = [];xHorAdj = [];yHorAdj = [];zHorAdj = [];
for(i=1:1:rows-1)
    if(excel(i,IndexOfFunc)==IsVerticalAdjustment)
        xVerAdj = [xVerAdj excel(i,2)];yVerAdj = [yVerAdj excel(i,3)];zVerAdj = [zVerAdj excel(i,4)];
    else
        xHorAdj = [xHorAdj excel(i,2)];yHorAdj = [yHorAdj excel(i,3)];zHorAdj = [zHorAdj excel(i,4)];
    end
    for(j=1:1:rows)
        if(j==1 || i==j)
            distance(i,j) = +inf;
        else
            distance(i,j) = sqrt((excel(i,2)-excel(j,2))^2+(excel(i,3)-excel(j,3))^2+(excel(i,4)-excel(j,4))^2);
            sumRow(i,1) = sumRow(i,1)+1;
            if(j==rows)
                if(distance(i,j)*delta>theta)
                    distance(i,j) = +inf;
                    sumRow(i,1) = sumRow(i,1)-1;
                else
                    % 可以到达终点
                    sumRow(i,2) = 1;
                end
            else
                if(excel(j,IndexOfFunc)==IsVerticalAdjustment)
                    %垂直误差校正
                    if(distance(i,j)*delta>min(VerticalAdjustVertical,VerticalAdjustHorizontal))
                        distance(i,j) = +inf;
                        sumRow(i,1) = sumRow(i,1)-1;
                    end
                else
                    %水平误差校正
                    if(distance(i,j)*delta>min(HorizontalAdjustVertical,HorizontalAdjustHorizontal))
                        distance(i,j) = +inf;
                        sumRow(i,1) = sumRow(i,1)-1;
                    end
                end
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%
%%% Plot Scattered dots
scatter3(xVerAdj,yVerAdj,zVerAdj,2,[1 0 0]);
hold on;
scatter3(xHorAdj,yHorAdj,zHorAdj,2,[0 0 1]);
%%%%%%%%%%%%%%%%%%%%%
% A-star,定义F-function直接用fn=n与邻近点的距离，越大，优先级越高，来源：魏王
% Intuitions: fn其他的可以设计的方法：与终点的欧式距离


% 初始化open_set和close_set
open_set = containers.Map({0},{1}); close_set = containers.Map({0},{1});open_set_list = []; parent = zeros(rows,1);
back_open_set_list = [];
% 将起点加入open_set中，并设置优先级为0（优先级最高）
open_set(1) = 1;back_open_set_list(length(back_open_set_list)+1,:) = [1 0 0 0 0 0 0];% 格式：节点 优先级 vertical horizontal xADir yADir

% 全局只有一个
globalDeltaVertical = 0;globalDeltaHorizontal = 0;globalTime = 0;determinedDis = 0;round = 1;
while(open_set.Count~=1) % 或者~isempty(back_open_set_list)==0
    open_set_list = [open_set_list;back_open_set_list];back_open_set_list = [];
    [r,c] = size(open_set_list);
    
    open_set_list = sortrows(open_set_list,SORT_ORDER*2);
    currNode = open_set_list(1,1);
    % 累加路程
    determinedDis =  determinedDis + open_set_list(1,5);
%     globalTime = globalTime+open_set_list(1,2);
    globalDeltaVertical = open_set_list(1,3);globalDeltaHorizontal = open_set_list(1,4);
    % 存储的方向信息
    xADir = open_set_list(1,5);yADir = open_set_list(1,6);
    disp(['OpenSetCount: ' num2str(open_set.Count-1) ' , openSetList: ' num2str(r) ' , globalTime: ' num2str(determinedDis)])
    if(currNode==rows)
        % 从终点开始逐步追踪parent节点，一直达到起点，返回找到的结果路径，算法结束
        disp('[ A-star reached ending...Printing parents]');pNode = currNode;count = 0;finalTime = 0;
        sumNodeX = [];sumNodeY = [];sumNodeZ = [];NODES = [];
        while(1)
            disp([num2str(pNode) ' ' num2str(finalTime)]);
            NODES = [pNode NODES];
            count = count+1;
            if(pNode==1)
                plot3(sumNodeX,sumNodeY,sumNodeZ);
                break;
            end
            preNode = pNode;
            sumNodeX = [sumNodeX excel(preNode,2)];sumNodeY = [sumNodeY excel(preNode,3)];sumNodeZ = [sumNodeZ excel(preNode,4)];
            pNode = parent(pNode);
            dis  = distance(pNode,preNode);
            finalTime = finalTime + dis;
        end
        disp(['-> Count: ' num2str(count) '-> globalTime: ' num2str(finalTime)]);
        break;
    else
        % 将节点n从open_set中删除，并加入close_set中
       remove(open_set,currNode);
       close_set(currNode) = 1;
        % 遍历节点n所有的邻近节点
       for(col=1:1:rows)
                dis  = distance(currNode,col);
                xA = excel(currNode,2);yA = excel(currNode,3);zA = excel(currNode,4);
                xB = excel(col,2);yB = excel(col,3);zB = excel(col,4);
%                 zB = excel(col,2);yB = excel(col,3);
                if(dis~=+inf)
                    % 可以连通
                    horDist = sqrt((xB-xA)^2+(yB-yA)^2);% 映射到平面上的欧氏距离
                    verDist = sqrt((excel(col,4)-excel(currNode,4))^2);% 高度上的欧氏距离
%                     dis = distFunc(horDist,verDist,distance(currNode,col)); % horizontalDistance,verticalDistance,originalDistance
                    % distance与第一题有区别,不再考虑z坐标
                    if(xADir==0 && yADir==0)
                        % 直接直线
                        dirX = xB-xA;
                        dirY = yB-yA;
                    else
                        % 转化为一段圆弧加一段直线
                        
                        [dis,dirX,dirY] = CircleAndStraight(xA,yA,xADir,yADir,xB,yB,dis); % xA,yA,xADir,yADir,xB,yB
                        dis = sqrt(dis^2+(zA-zB)^2);
                    end
                    % 这边不需要额外判断dis是否会超界，因为下面的边界计算也会判断
                    CurrDeltaVertical = globalDeltaVertical + delta*dis;CurrDeltaHorizontal = globalDeltaHorizontal + delta*dis;
                    if(excel(col,IndexOfFunc)==IsVerticalAdjustment)
                        % 是垂直矫正
                        if(CurrDeltaVertical<=VerticalAdjustVertical && CurrDeltaHorizontal<=VerticalAdjustHorizontal)
                            % 此时没有超出范围
                            if(isKey(close_set,col)==1)
                                % 如果邻近节点m在close_set中，则跳过，选取下一个邻近节点
                            elseif(isKey(open_set,col)==0)
                                % 如果邻近节点m也不在open_set中
                                % 设置节点m的parent为节点n
                                % 计算节点m的优先级
                                % 将节点m加入open_set中
                                parent(col) = currNode;
                                % 1. dis DESC 2. CurrDeltaVertical+dis DESC 3. 与终点距离 ASC
%                                 fn = CurrDeltaVertical;% 为相邻节点之间的距离，越大越好 
                                fn = sqrt((excel(col,2)-excel(rows,2))^2+(excel(col,3)-excel(rows,3))^2+(excel(col,4)-excel(rows,4))^2);
                                open_set(col) = 1;
                                [r,c] = size(back_open_set_list);
                                back_open_set_list(r+1,:) = [col fn 0 CurrDeltaHorizontal dis dirX dirY];
                                
                            end
                        end 
                    else
                        % 是水平矫正
                        if(CurrDeltaVertical<=HorizontalAdjustVertical && CurrDeltaHorizontal<=HorizontalAdjustHorizontal)
                            % 此时没有超出范围
                            if(isKey(close_set,col)==1)
                                % 如果邻近节点m在close_set中，则跳过，选取下一个邻近节点
                            elseif(isKey(open_set,col)==0)
                                % 如果邻近节点m也不在open_set中
                                % 设置节点m的parent为节点n
                                % 计算节点m的优先级
                                % 将节点m加入open_set中
                                parent(col) = currNode;
                                % 1. dis DESC 2. CurrDeltaVertical+dis DESC 3. 与终点距离 ASC
%                                 fn = CurrDeltaHorizontal;% 为相邻节点之间的距离，越大越好 
                                fn = sqrt((excel(col,2)-excel(rows,2))^2+(excel(col,3)-excel(rows,3))^2+(excel(col,4)-excel(rows,4))^2);
                                open_set(col) = 1;
                                [r,c] = size(back_open_set_list);
                                back_open_set_list(r+1,:) = [col fn CurrDeltaVertical 0 dis dirX dirY];
                            end
                        end
                    end
                    
                end
       end
    end
        % open_list删除当前节点
    open_set_list = open_set_list(2:end,:);
    round = round+1;
end

%%% Walk Again
parent(1) = rows;
deltaVer = [];deltaHor = [];time = [];type = [];
disp('Rewalk...');finalTime = 0;Ver = 0;Hor = 0;
        sumNodeX = [];sumNodeY = [];sumNodeZ = [];
        for(i=2:1:length(NODES))
            pNode = NODES(i);
            
%             sumNodeX = [sumNodeX excel(preNode,2)];sumNodeY = [sumNodeY excel(preNode,3)];sumNodeZ = [sumNodeZ excel(preNode,4)];
            preNode = NODES(i-1);
            dis  = distance(preNode,pNode);Ver = Ver+dis*delta;Hor = Hor+dis*delta;
            deltaVer = [deltaVer Ver];deltaHor = [deltaHor Hor];
            if(excel(pNode,IndexOfFunc)==IsVerticalAdjustment)
                Ver = 0;type = [type num2str(IsVerticalAdjustment)];
            else
                Hor = 0;type = [type num2str(IsHorizontalAdjustment)];
            end
            finalTime = finalTime + dis;
            time = [time finalTime];
        end
        
  deltaVer
deltaHor
type      


saveas(gca,'astar_2_1.fig');
saveas(gca,'astar_2_1.bmp');
%  hold on;
%  
%  
%  
%  hold off;


