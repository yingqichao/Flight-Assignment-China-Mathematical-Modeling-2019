%%%%%%
% memorized-BFS Solution of Question 1
% Author: Qichao Ying
% Date: 19/9/20
%%%%%%

clear all;
excel=xlsread('1.xlsx');
%%%%%%Setting%%%%%%%%
VerticalAdjustMinVertical = 25;
VerticalAdjustMinHorizontal = 15;
HorizontalAdjustMinVertical = 20;
HorizontalAdjustMinHorizontal = 25;
theta = 30;
delta = 0.001;
IndexOfFunc = 5;
IsVerticalAdjustment = 1;IsHorizontalAdjustment = 0;

alpha = 1;beta = [0];

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
                    if(distance(i,j)*delta>min(VerticalAdjustMinVertical,VerticalAdjustMinHorizontal))
                        distance(i,j) = +inf;
                        sumRow(i,1) = sumRow(i,1)-1;
                    end
                else
                    %水平误差校正
                    if(distance(i,j)*delta>min(HorizontalAdjustMinVertical,HorizontalAdjustMinHorizontal))
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
scatter3(xVerAdj,yVerAdj,zVerAdj,1,[1 0 0]);
hold on;
scatter3(xHorAdj,yHorAdj,zHorAdj,1,[0 0 1]);
%%%%%%%%%%%%%%%%%%%%%
%%% Brute Force
ROND = [];DIST = [];

route = containers.Map({0},{''});newRoute = containers.Map({0},{''});
for(p = 1:1:length(beta))
    disp(['------------ beta ' num2str(beta) '--------------' ]);
    %%% Initialize
    optimized = containers.Map({1},{1}); optimized_path = containers.Map({1},{1});
    listAt = [];listDeltaVertical = [];listDeltaHorizontal = [];listTime = [];
    backlistAt = [1];backlistDeltaVertical = [0];backlistDeltaHorizontal = [0];backlistTime = [0];newRoute(1) = '1';
    round = 1;global_min = +inf;whichround = -1;howlong = -1;
    disp(['Round:' num2str(round)]);disp(['Stack Remains: ' num2str(length(backlistAt))]);
    while(~isempty(backlistAt))
        route_index = 1;old_route_index = 1;
        min_time = +inf;
        disp(['Round:' num2str(round)]);disp(['Stack Remains: ' num2str(length(backlistAt))]);
        %%%%% Reset
        route = newRoute;newRoute = containers.Map({0},{''});
        listTime = backlistTime;listAt = backlistAt;listDeltaVertical = backlistDeltaVertical;listDeltaHorizontal = backlistDeltaHorizontal;
        backlistTime = [];backlistAt = [];backlistDeltaVertical = [];backlistDeltaHorizontal = [];
        
        while(~isempty(listAt))
            % 获取之前的路径
            if(isKey(route,old_route_index)~=0) 
                preRoute = route(old_route_index);
            else
                preRoute = '';
            end
            PrevPosition = listAt(1);PrevDeltaVertical = listDeltaVertical(1);PrevDeltaHorizontal = listDeltaHorizontal(1);PrevTime = listTime(1);
%             if(...
%                 (excel(PrevPosition,IndexOfFunc)==IsVerticalAdjustment && optimized(PrevPosition)<=PrevDeltaHorizontal && optimized_path(PrevPosition)<PrevTime) || ...
%                 (excel(PrevPosition,IndexOfFunc)==IsHorizontalAdjustment && optimized(PrevPosition)<=PrevDeltaVertical && optimized_path(PrevPosition)<PrevTime) ...
%                )
%                 % 如果当前位置不是最短的状态，则不进行后续查找
%                 listAt = listAt(2:end);listDeltaVertical = listDeltaVertical(2:end);listDeltaHorizontal = listDeltaHorizontal(2:end);
%                 continue;
%             end
            for(col=1:1:rows)
                dis  = distance(PrevPosition,col);
                if(dis~=+inf)
                    % 可以连通
                    CurrDeltaVertical = PrevDeltaVertical + delta*dis;CurrDeltaHorizontal = PrevDeltaHorizontal + delta*dis;
                    CurrTime = PrevTime + dis;
                    if(excel(col,IndexOfFunc)==IsVerticalAdjustment)
                        % 是垂直矫正
                        if(CurrDeltaVertical<=VerticalAdjustMinVertical && CurrDeltaHorizontal<=VerticalAdjustMinHorizontal)
                            % 此时没有超出范围
                            if(isKey(optimized,col)==0 || optimized(col)>CurrDeltaHorizontal || (optimized(col)==CurrDeltaHorizontal && optimized_path(col)>CurrTime))
                                % 如果Horizontal偏差创出新的最小值，则存进list,终点不存
                                if(col~=rows)
                                    % 保存路径
                                    
                                    currRoute = [preRoute ' ' num2str(col)];
                                    newRoute(route_index) = currRoute;
                                
                                    route_index = route_index+1;
                                    backlistAt = [backlistAt col];
                                    backlistDeltaVertical = [backlistDeltaVertical 0];
                                    backlistDeltaHorizontal = [backlistDeltaHorizontal CurrDeltaHorizontal];
                                    backlistTime = [backlistTime CurrTime];
                                    min_time = min(min_time,CurrTime);
                                else
                                    % 到了终点
                                    disp(['Reach Ending..  ' num2str(CurrTime)]);
                                    disp(['> Path: ' preRoute ' ' num2str(col)])
                                    if(global_min>alpha*CurrTime+beta(p)*(round+1))
                                        global_min = min(global_min,alpha*CurrTime+beta(p)*(round+1));
                                        currMinPath = [preRoute ' ' num2str(col)];
                                        whichround = (round+1);howlong = CurrTime;
                                    end
                                end
                                % 更新Map
                                if(isKey(optimized,col)==0 || optimized(col)>CurrDeltaHorizontal || (optimized_path(col)>CurrTime && optimized(col)==CurrDeltaHorizontal))
                                    optimized(col) = CurrDeltaHorizontal;optimized_path(col) = CurrTime;
                                end
                            end
                        end 
                    else
                        % 是水平矫正
                        if(CurrDeltaVertical<=HorizontalAdjustMinVertical && CurrDeltaHorizontal<=HorizontalAdjustMinHorizontal)
                            % 此时没有超出范围
                            if(isKey(optimized,col)==0 || optimized(col)>CurrDeltaVertical || (optimized(col)==CurrDeltaVertical && optimized_path(col)>CurrTime))
                                % 如果Horizontal偏差创出新的最小值，则存进list
                                if(col~=rows)
                                    % 保存路径
                                    
                                    currRoute = [preRoute ' ' num2str(col)];
                                    newRoute(route_index) = currRoute;
                                    
                                    route_index = route_index+1;
                                    
                                    backlistAt = [backlistAt col];
                                    backlistDeltaVertical = [backlistDeltaVertical CurrDeltaVertical];
                                    backlistDeltaHorizontal = [backlistDeltaHorizontal 0];
                                    backlistTime = [backlistTime CurrTime];
                                    min_time = min(min_time,CurrTime);
                                else
                                    % 到了终点
                                    disp(['Reach Ending..  ' num2str(CurrTime)]);
                                    disp(['> Path: ' preRoute ' ' num2str(col)])
                                    if(global_min>alpha*CurrTime+beta(p)*(round+1))
                                        global_min = min(global_min,alpha*CurrTime+beta(p)*(round+1));
                                        currMinPath = [preRoute ' ' num2str(col)];
                                        whichround = (round+1);howlong = CurrTime;
                                    end
                                end
                                % 更新Map
                                if(isKey(optimized,col)==0 || optimized(col)>CurrDeltaVertical || (optimized_path(col)>CurrTime && optimized(col)==CurrDeltaVertical))
                                    optimized(col) = CurrDeltaVertical;optimized_path(col) = CurrTime;
                                end
                            end
                        end
                    end
                end
            end
            listAt = listAt(2:end);listDeltaVertical = listDeltaVertical(2:end);listDeltaHorizontal = listDeltaHorizontal(2:end);listTime = listTime(2:end);
            old_route_index = old_route_index +1;
        end

        round = round + 1;
        disp(['Min Time:' num2str(min_time)]);
    end

    disp(['最终的 GLOBAL MIN SUM : ' num2str(global_min) ' At round ' num2str(whichround)  ' with MIN DISTANCE ' num2str(howlong)]);
    ROND = [ROND whichround];DIST = [DIST howlong];
    disp(currMinPath);
    
    %%% Test
    S = regexp(currMinPath, '\s+', 'split');pathSum = 0;sumNodeX = [];sumNodeY = [];sumNodeZ = [];
    for i=2:1:length(S)
        curr = str2num(S{i});prev = str2num(S{i-1});
        sumNodeX = [sumNodeX excel(curr,2)];sumNodeY = [sumNodeY excel(curr,3)];sumNodeZ = [sumNodeZ excel(curr,4)];
        if(i==2)
            sumNodeX = [excel(prev,2) sumNodeX];sumNodeY = [excel(prev,3) sumNodeY];sumNodeZ = [excel(prev,4) sumNodeZ];
        end
        d = distance(prev,curr);
        pathSum = pathSum + d;
    end
    plot3(sumNodeX,sumNodeY,sumNodeZ);
    disp(['总路径： ' num2str(pathSum)]);
    
   %%% Walk Again
    S = regexp(currMinPath, '\s+', 'split');pathSum = 0;sumNodeX = [];sumNodeY = [];sumNodeZ = [];
    deltaVer = [];deltaHor = [];time = [];type = [];
disp('Rewalk...');finalTime = 0;Ver = 0;Hor = 0;
        sumNodeX = [];sumNodeY = [];sumNodeZ = [];
    for i=2:1:length(S)
        pNode = str2num(S{i});preNode = str2num(S{i-1});
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
    
    %%% Walk Again
% parent(1) = rows;
% deltaVer = [];deltaHor = [];time = [];type = [];
% disp('Rewalk...');finalTime = 0;Ver = 0;Hor = 0;
%         sumNodeX = [];sumNodeY = [];sumNodeZ = [];
%         for(i=2:1:length(NODES))
%             pNode = NODES(i);
%             
% %             sumNodeX = [sumNodeX excel(preNode,2)];sumNodeY = [sumNodeY excel(preNode,3)];sumNodeZ = [sumNodeZ excel(preNode,4)];
%             preNode = NODES(i-1);
%             dis  = distance(preNode,pNode);Ver = Ver+dis*delta;Hor = Hor+dis*delta;
%             deltaVer = [deltaVer Ver];deltaHor = [deltaHor Hor];
%             if(excel(pNode,IndexOfFunc)==IsVerticalAdjustment)
%                 Ver = 0;type = [type num2str(IsVerticalAdjustment)];
%             else
%                 Hor = 0;type = [type num2str(IsHorizontalAdjustment)];
%             end
%             finalTime = finalTime + dis;
%             time = [time finalTime];
%         end
    
end

saveas(gca,'bt_1_1.fig');
saveas(gca,'bt_1_1.emf');
%  hold on;
%  
%  
%  
%  hold off;
