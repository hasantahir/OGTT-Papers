%Cohort 1: Train for CQ1- Prediction of DMI 
%Maximize Sensitivity
%Last Edit by Marelyn Rios July 3, 2018
 
clear all; close all; clc;
% Age and BMI are included as features
warning('off','all') % To supress warnings due to svmtrain and svmclassify
% First weed out all the rows with any zero values
load('features_finite_features_eth.mat')
% ft contains a table of all the features with column headers
FT = table2array(SAHS_features);
FT(:,12:20)=[]; FT(:,end)=[]; 
numFeatures = size(FT,2); % add one for label

FT=array2table(FT);
% The computed features are stored from 17-60 columns
labels = Labels;

%%% Variable information
% Data -- table of all extracted and some raw features like age and BMI
% label  -- classifier ( 0 or 1)
% Construct positive and negative class
labels(labels==1) = -1; labels(labels==2) = -1; %negative class (Non DMI)
labels(labels==3) = 1; labels(labels==4) = 1; %positive class (DMI)

% Find DMI samples
idx = find (labels == 1);
% r = rem(length(idx),10); %calculates remainder 
data_length = length(idx); %this will be subset length

%randomly select this many rows 
shuffle = randperm(data_length); %these are row indices 
idx = idx(shuffle,:); %rows have been shuffled 

% Extract features of DMI samples
PCdata_train = FT{idx(1:160), :};
PCdata_test = FT{idx(161:end), :}; %validation part 1 

% Extract the remaining Non-DMI samples
non_data = FT{:, :};
non_data(idx,:) = []; %deletes the dmi indices

%create validation set 
shuffle_neg = randperm(length(non_data)); %shuffle 1302 
NCdata_test = non_data(shuffle_neg(1:11),:); %test ratio same as overall ratio
non_data(1:1,:) = []; %deletes val from non_data


% Randomly generate a dataset from non_data equal to the size of data
data_length = length(PCdata_train);
non_data_length = length(non_data);
rand_idx = randperm (non_data_length , data_length);
NCdata_train = non_data(rand_idx,:);

%combine the train & test
Label_Train = [ones(size(PCdata_train,1),1); zeros(size(NCdata_train,1),1)]; 
Label_Test = [ones(size(PCdata_test,1),1); zeros(size(NCdata_test,1),1)]; 

Data_Train = vertcat(PCdata_train, NCdata_train);
Data_Test = vertcat(PCdata_test,NCdata_test); 
DMI_Train = table(horzcat(Data_Train,Label_Train));
DMI_Test = table(horzcat(Data_Test,Label_Test));

%add labels to the table 
names = SAHS_features.Properties.VariableNames; %name of each predictor 
names(:,12:20) =[]; 
Names = string(names);
% names(1);
% for i = 1:size(names,2)
%     %c_name = names(i); 
%     DMI_Train.Properties.VariableNames(i)= names(i);
%     DMI_Test.Properties.VariableNames{i} = names(i);
% end 

writetable(DMI_Train,'DMI_Train_Eth.xlsx','Sheet',1);
writetable(DMI_Test,'DMI_Test_Eth.xlsx','Sheet',1);


