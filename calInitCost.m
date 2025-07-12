function initCost = calInitCost(censusL, censusR, minDisparity, maxDisparity)
% 计算初始代价空间
% 输入:
%   censusL, censusR - 左图和中图的census值(uint32)
%   minDisparity, maxDisparity - 最小和最大视察范围
% 输出:
%   initCost - 初始代价空间

[height, width] = size(censusL);
rangeDisparity = minDisparity:maxDisparity;
initCost = ones(height, width, length(rangeDisparity)) * 10000;

for row = 1:height
    for col = 1:width
        idDisp = 0;
        for disp = minDisparity:maxDisparity
            idDisp = idDisp + 1;
            % 判断是否超出范围
            if(col + disp < 1 || col + disp > width)
                continue;
            end
            
            dist = HammingDis(censusL(row, col), censusR(row, col + disp));
            initCost(row, col, idDisp) = dist;
        end
    end
end


end