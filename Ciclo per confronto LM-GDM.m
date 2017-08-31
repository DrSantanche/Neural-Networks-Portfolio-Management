xlsread('C:\Users\marco\Documents\UniversitÓ\TESI\historyIndex.xls','A7:F1501')
Germ=ans(:,1)
It=ans(:,2)
Jap=ans(:,3)
NA=ans(:,4)
UK=ans(:,5)
GermRet=diff(log(Germ))*100;
ItRet=diff(log(It))*100;
JapRet=diff(log(Jap))*100;
NARet=diff(log(NA))*100;
UKRet=diff(log(UK))*100;
% Solve an Autoregression Time-Series Problem with a NAR Neural Network
% Script generated by Neural Time Series app
% Created 13-Apr-2017 09:32:27
%
% This script assumes this variable is defined:
%
%   target - feedback time series.
target=[GermRet ItRet JapRet NARet UKRet];
%target = [Germ It Jap NA UK]
T = tonndata(target,false,false);

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';
% Create a Nonlinear Autoregressive Network
feedbackDelays = 1:2;
hiddenLayerSize = 5;
storelm=zeros(3,100)
for i=(1:100)
net = narnet(feedbackDelays,hiddenLayerSize,'open',trainFcn);
net.trainParam.max_fail=10
net.trainParam.num_epochs=10000
net.trainParam.lr=0.01
% Choose Feedback Pre/Post-Processing Functions
% Settings for feedback input are automatically applied to feedback output
% For a list of all processing functions type: help nnprocess
net.input.processFcns = {'removeconstantrows','mapminmax'};

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.
[x,xi,ai,t] = preparets(net,{},{},T);
i

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'time';  % Divide up every sample
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse';  % Mean Squared Error

% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate', 'ploterrhist', ...
    'plotregression', 'plotresponse', 'ploterrcorr', 'plotinerrcorr'};

% Train the Network
[net,tr] = train(net,x,t,xi,ai);

% Test the Network
y = net(x,xi,ai);
e = gsubtract(t,y);
performance = perform(net,t,y);

% Recalculate Training, Validation and Test Performance
trainTargets = gmultiply(t,tr.trainMask);
valTargets = gmultiply(t,tr.valMask);
testTargets = gmultiply(t,tr.testMask);
trainPerformance = perform(net,trainTargets,y);
valPerformance = perform(net,valTargets,y);
testPerformance = perform(net,testTargets,y);
storelm(1,i)=testPerformance;
storelm(2,i)=valPerformance;
storelm(3,i)=testPerformance;
end
% View the Network
%view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)
