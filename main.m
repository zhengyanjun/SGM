clear
close all
clc



%% 加载相机参数，极限拉平
disp('加载相机参数，极限拉平...');
load('./data/calibrationSession.mat'); 
stereoParams = stereoParameters(calibrationSession.CameraParameters.CameraParameters1,calibrationSession.CameraParameters.CameraParameters2,calibrationSession.CameraParameters.PoseCamera2);

imgL = imread('./data/L/23.bmp');
imgR = imread('./data/R/23.bmp');

imgBGL = imread('./data/L/2.bmp');
imgBGR = imread('./data/R/2.bmp');

% 转换为灰度图像（如果必要）
if size(imgL, 3) == 3
    leftGray = rgb2gray(imgL);
    rightGray = rgb2gray(imgR);
    leftGrayBG = rgb2gray(imgBGL);
    rightGrayBG = rgb2gray(imgBGR);
else
    leftGray = imgL;
    rightGray = imgR;
    leftGrayBG = imgBGL;
    rightGrayBG = imgBGR;
end

% 显示原始图像
figure;
subplot(1,2,1); imshow(leftGray); title('左原始图像');
subplot(1,2,2); imshow(rightGray); title('右原始图像');

%极线拉平
[rectifiedLeft_, rectifiedRight_, reprojectionMatrix] = rectifyStereoImages(leftGray, rightGray, stereoParams, OutputView='full');
[rectifiedLeftBG_, rectifiedRightBG_, reprojectionMatrix_] = rectifyStereoImages(leftGrayBG, rightGrayBG, stereoParams, OutputView='full');

% % 显示校正后的图像
% figure;
% subplot(1,2,1); imshow(rectifiedLeft_); title('左图极线拉平');
% subplot(1,2,2); imshow(rectifiedRight_); title('右图极线拉平');

% 把左图和右图偏移一下
wCrop = 400;
xL0 = 770;
xR0 = 200;

rectifiedLeft = rectifiedLeft_(:,xL0:(xL0+wCrop));
rectifiedRight = rectifiedRight_(:,xR0:(xR0+wCrop));
figure;
subplot(1,2,1); imshow(rectifiedLeft); title('左图极线拉平');
subplot(1,2,2); imshow(rectifiedRight); title('右图极线拉平');

rectifiedLeftBG = rectifiedLeftBG_(:,xL0:(xL0+wCrop));
rectifiedRightBG = rectifiedRightBG_(:,xR0:(xR0+wCrop));
figure;
subplot(1,2,1); imshow(rectifiedLeftBG); title('左背景图极线拉平');
subplot(1,2,2); imshow(rectifiedRightBG); title('右背景图极线拉平');

gThr = 50;
maskL = double(rectifiedLeftBG > gThr);
maskR = double(rectifiedRightBG > gThr);
figure;
subplot(1,2,1); imshow(maskL); title('左背景图极线拉平');
subplot(1,2,2); imshow(maskR); title('右背景图极线拉平');

[height, width] = size(rectifiedLeft);
%% 计算初始代价空间
% 计算左右图的census值
disp('计算左右图的census值...');
winSize = 5;
censusL = census_transform(rectifiedLeft, winSize);
censusR = census_transform(rectifiedRight, winSize);

% 定义时差范围
minDisparity = -36;
maxDisparity = 36;

initCost = calInitCost(censusL, censusR, minDisparity, maxDisparity);

if 0
    initDisparity = calDisparityWAT(initCost, minDisparity, maxDisparity);
    figure;
    imshow(initDisparity, []);
end

% 进行代价聚合
P1 = 10;
P2 = 120;

disp('从左到右聚合...');
aggPath = [0, -1];  % row-0, col-1 ==> 从左到右聚合
aggCost1 = aggCost(initCost, aggPath, P1, P2);

disp('从右到左聚合...');
aggPath = [0, 1];  % 从右到左聚合
aggCost2 = aggCost(initCost, aggPath, P1, P2);

disp('从上到下聚合...');
aggPath = [-1, 0];  % 从上到下聚合
aggCost3 = aggCost(initCost, aggPath, P1, P2);

disp('从下到上聚合...');
aggPath = [1, 0];  % 从下到上聚合
aggCost4 = aggCost(initCost, aggPath, P1, P2);

aggCost_1_4 = aggCost1 + aggCost2 + aggCost3 + aggCost4;

if 1
    aggDisparity_1_4 = calDisparityWAT(aggCost_1_4, minDisparity, maxDisparity);
    aggDisparity_1_4 = aggDisparity_1_4.*maskL;
    figure;
    imshow(aggDisparity_1_4, []);
end

disp('从左上到右下聚合...');
aggPath = [-1, -1];  % row-0, col-1 ==> 从左到右聚合
aggCost5 = aggCost(initCost, aggPath, P1, P2);

disp('从右上到左下聚合...');
aggPath = [-1, 1];  % 从右到左聚合
aggCost6 = aggCost(initCost, aggPath, P1, P2);

disp('从左下到右上聚合...');
aggPath = [1, -1];  % 从上到下聚合
aggCost7 = aggCost(initCost, aggPath, P1, P2);

disp('从右下到左上聚合...');
aggPath = [1, 1];  % 从下到上聚合
aggCost8 = aggCost(initCost, aggPath, P1, P2);


aggCost_1_8 = aggCost_1_4 + aggCost5 + aggCost6 + aggCost7 + aggCost8;

if 1
    aggDisparity_1_8 = calDisparityWAT(aggCost_1_8, minDisparity, maxDisparity);
    aggDisparity_1_8 = aggDisparity_1_8.*maskL;
    figure;
    imshow(aggDisparity_1_8, []);
end





