function aggCost = aggCost(cost, aggPath, P1, P2)
% 在路径aggPath上，进行代价聚合
% 输入:
%   cost - 代价空间
%   aggPath - 聚合路径
%   P1, P2 - P1和P2惩罚
% 输出:
%   aggCost - 聚合代价

[height, width, numDisp] = size(cost);

% 判断聚合方向，确定遍历图像顺序
% 默认从左到有
rangeY = 1:height;
rangeX = 1:width;
% aggPath = [0, -1]  row-0, col-1 ==> 从左到右聚合
if aggPath(2) == 1
    % 从右到左
    rangeX = width:-1:1;
end
if aggPath(1) == 1
    % 从上到下
    rangeY = height:-1:1;
end

for row = rangeY
    for col = rangeX
        rowP = aggPath(1)+row;
        colP = aggPath(2)+col;
        if rowP < 1 || rowP > height || colP < 1 || colP > width
            continue;
        end
        costPath = cost(rowP, colP, :);
        % 计算路径上最小的代价
        minCostPath = min(costPath);
        for idDisp = 1:numDisp
            % 同视差
            cost0 = costPath(idDisp);
            % 视察相差一个像素
            cost1_up = 10000;
            if(idDisp - 1 > 0)
                cost1_up = costPath(idDisp - 1);
            end
            cost1_down = 10000;
            if(idDisp + 1 <= numDisp)
                cost1_down = costPath(idDisp + 1);
            end
            
            % 代价聚合
            cost(row, col, idDisp) = cost(row, col, idDisp) + ...
                min([cost0, cost1_up + P1, cost1_down + P1, minCostPath + P2]) - minCostPath;
        end
    end
end

aggCost = cost;

end