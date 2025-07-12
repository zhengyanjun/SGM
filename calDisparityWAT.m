function valDisparity = calDisparityWAT(cost, minDisparity, maxDisparity)
% 计算赢者通吃的视察值
% 输入:
%   cost - 代价空间
%   minDisparity, maxDisparity - 最小和最大视察范围
% 输出:
%   valDisparity - 最小代价处的时差值

[height, width, numDisp] = size(cost);
rangeDisparity = minDisparity:maxDisparity;
valDisparity = zeros(height, width);

for row = 1:height
    for col = 1:width
        costVec = cost(row, col, :);
        [minCost,id] = min(costVec);
        valDisparity(row, col) = rangeDisparity(id);
    end
end


end