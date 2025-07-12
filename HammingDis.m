function dist = HammingDis(x, y)
% 计算两个32位无符号整数的汉明距离
% 输入:
%   x, y - 要比较的两个32位无符号整数(uint32)
% 输出:
%   dist - 汉明距离(uint8)

% 计算异或结果
val = bitxor(x, y);

% 初始化距离计数器
dist = uint8(0);

% 计算置位比特数(Kernighan算法)
while val ~= 0
    dist = dist + 1;
    val = bitand(val, val - 1); % 清除最低位的1
end
end