function censusVal = census_transform(imgGrag, winSize)
% Census变换实现
% 输入:
%   source - 输入图像矩阵(灰度图, uint8类型)
%   winSize - 计算窗口大小
% 输出:
%   census - Census变换结果矩阵(uint32类型)

% 不能超过uint32的内存
if winSize>5
    return;
end

halfWinSize = floor(winSize/2);
[height, width] = size(imgGrag);

% 初始化输出矩阵
censusVal = zeros(height, width, 'uint32');

% 检查输入有效性
if isempty(imgGrag) || width < winSize || height < winSize
    return;
end

% 逐像素计算census值(忽略边界halfWinSize像素)
for i = (halfWinSize+1):(height-halfWinSize)
    for j = (halfWinSize+1):(width-halfWinSize)
        % 中心像素值
        gray_center = imgGrag(i, j);
        
        % 初始化census值
        census_val = uint32(0);
        
        % 遍历winSize x winSize窗口
        for r = -halfWinSize:halfWinSize
            for c = -halfWinSize:halfWinSize
                census_val = bitshift(census_val, 1); % 左移1位
                
                % 比较邻域像素与中心像素
                if imgGrag(i+r, j+c) < gray_center
                    census_val = census_val + 1;
                end
            end
        end
        
        % 存储结果
        censusVal(i, j) = census_val;
    end
end
end