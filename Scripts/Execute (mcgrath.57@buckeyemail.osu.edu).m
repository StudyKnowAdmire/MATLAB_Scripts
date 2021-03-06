
% clc; close all; clear all

% gamma bigger, the exp(-gamma*x) curve is more curly,otherwise more
% straight

SetEnvironment
SetPath

%path_data_human = strcat(g_str_pathbase_data,'\training\test_human_onedata'); %REPLACE: human - 406
%path_data_dog   = strcat(g_str_pathbase_data,'\training\test_dog_onedata'); %REPLACE: ball - 408

% Index = [17,18,19,20]; %205 246
% data_human = {'\IPSNdata\loc_17','\IPSNdata\AveryPark_18','\IPSNdata\NearForest_19','NIL'};
% data_dog = {'NIL','NIL','NIL','\IPSNdata\RadarPendulumData-ParkingLot_20'};



% Index = [3]; %205 246
% data_human = {'\IPSNdata\kh_3\Human'};
% data_dog = {'\IPSNdata\kh_3\Dog'};

% Index = [6,7,8,9,10,11];
% data_human = {'\IPSNdata\9603_6','\IPSNdata\Glacier_Ridge_7','\IPSNdata\Ballantrae_8','\IPSNdata\Coffman_9','\IPSNdata\ceiling_238_10\Human','NIL'};
% data_dog =   {'NIL',             'NIL',                      'NIL',                   'NIL',                '\IPSNdata\ceiling_238_10\Dog',  '\IPSNdata\dog_cut_11'};

% Index = [11,10,9,8,7,6];
% data_human = {'NIL',                 '\IPSNdata\ceiling_238_10\Human','\IPSNdata\Coffman_9','\IPSNdata\Ballantrae_8','\IPSNdata\Glacier_Ridge_7','\IPSNdata\9603_6'};
% data_dog =   {'\IPSNdata\dog_cut_11','\IPSNdata\ceiling_238_10\Dog',  'NIL',                'NIL',                   'NIL',                      'NIL'};

% Index = [12,13,14,15,16,17,18,19,20];
% data_human = { 'NIL'                , '\IPSNdata\kwon_milling_13', '\IPSNdata\r012_14', 'NIL'                      , '\IPSNdata\BryanPark_16', '\IPSNdata\loc_17', '\IPSNdata\AveryPark_18', '\IPSNdata\NearForest_19', 'NIL'};
% data_dog =   { '\IPSNdata\gudiya_12', 'NIL'                      , 'NIL'              , '\IPSNdata\rambling_rmc_15', 'NIL'                   , 'NIL'             , 'NIL'                   , 'NIL'                    , '\IPSNdata\RadarPendulumData-ParkingLot_20'};

%Index = [13,14,15,16,17,18,19,20];
%data_human = { '\IPSNdata\kwon_milling_13', '\IPSNdata\r012_14', 'NIL'                      , '\IPSNdata\BryanPark_16', '\IPSNdata\loc_17', '\IPSNdata\AveryPark_18', '\IPSNdata\NearForest_19', 'NIL'};
%data_dog =   { 'NIL'                      , 'NIL'              , '\IPSNdata\rambling_rmc_15', 'NIL'                   , 'NIL'             , 'NIL'                   , 'NIL'                    , '\IPSNdata\RadarPendulumData-ParkingLot_20'};

%g_str_pathbase_data='C:\Users\royd\Desktop';

%Index = [5162011, 11302011];
%data_dog = { '\IPSNdata\5-16-2011\Dog',  '\IPSNdata\11-30-2011' };
%data_human =   { 'NIL', 'NIL' };

%g_str_pathbase_data = 'C:\Users\researcher\Downloads\5-15-2011';
Index = [ 5152011 ];
data_dog = {'/IPSNdata/5-15-2011/Dog' };
data_human = {'/IPSNdata/5-15-2011/Human'};

% Index = [20,19,18,17,16,15,14,13,12];
% data_human = {  'NIL'                                     , '\IPSNdata\NearForest_19', '\IPSNdata\AveryPark_18', '\IPSNdata\loc_17', '\IPSNdata\BryanPark_16', 'NIL'                      , '\IPSNdata\r012_14', '\IPSNdata\kwon_milling_13', 'NIL' };
% data_dog =   { '\IPSNdata\RadarPendulumData-ParkingLot_20', 'NIL'                    , 'NIL'                   , 'NIL'             , 'NIL'                   , '\IPSNdata\rambling_rmc_15', 'NIL'              , 'NIL'                      , '\IPSNdata\gudiya_12' };


featureClass = 0;

%
% these two lines put here because when the below two lines are commented
% out, without these two lines the program does not run
% nFeatures = 18;
% feature_min = zeros(1,nFeatures);
% scalingFactors=zeros(1,nFeatures);

% Comment these two lines if doing feature collection instead of data
% collection (which means build the arff file manually), for example create
% a radar77.arff in text editor and record the feature values there using
% real time classifier and display the feature value in MFDeploy

for i=1:length(Index)
    OutIndex = Index(i);
    fprintf('Processing OutIndex=%d...\n', OutIndex);
    if strcmp(data_human{i},'NIL')==1
        [feature_min, scalingFactors] = Build_arff_dog(OutIndex,0,featureClass, 0, 0, data_dog{i}); %Compute unscaled features
        Build_arff_dog(OutIndex,1,featureClass, feature_min, scalingFactors, data_dog{i}); %Compute scaled features, cross-validate (suppressed, refer to RunResultScript_IoTDI.m)
    elseif strcmp(data_dog{i},'NIL')==1
        [feature_min, scalingFactors] = Build_arff_human(OutIndex,0,featureClass, 0, 0, data_human{i}); %Compute unscaled features (suppressed, refer to RunResultScript_IoTDI.m)
        Build_arff_human(OutIndex,1,featureClass, feature_min, scalingFactors, data_human{i}); %Compute scaled features, cross-validate (suppressed, refer to RunResultScript_IoTDI.m)
    else
        [feature_min, scalingFactors] = Build_arff(OutIndex,0,featureClass, 0, 0, data_human{i}, data_dog{i}); %Compute unscaled features (suppressed, refer to RunResultScript_IoTDI.m)
        Build_arff(OutIndex,1,featureClass, feature_min, scalingFactors, data_human{i}, data_dog{i}); %Compute scaled features, cross-validate (suppressed, refer to RunResultScript_IoTDI.m)
    end
    %
    %     fileName=[g_str_pathbase_radar,'\IIITDemo\Models\human_dog_model',int2str(OutIndex),'.txt'];%,int2str(OutIndex)
    %     [SV_matlab, param, gamma, rho, nRow]=Model2Matrix(fileName,length(feature_min));
    %
    %     % for j=1:size(SV_matlab,1)
    %     %     GenerateArrInCsharp(SV_matlab(j,:),['sv',int2str(j-1)]);
    %     % end
    %     Generate2DArrInCsharp(OutIndex,SV_matlab,param,gamma,rho,feature_min,scalingFactors);
    %     nSV = nRow;
    %
    %     % save model parameters MATLAB variables
    %     str_fftsource = strcat('_',getenv('USERNAME'),'_eMote');
    %
    %     str_pathbase_modelparameters = strcat(g_str_pathbase_radar,'\IIITDemo\Models\ModelParameters');
    %     if exist(str_pathbase_modelparameters, 'dir') ~= 7
    %         mkdir(str_pathbase_modelparameters);
    %         printf('INFO: created directory %s\n', str_pathbase_modelparameters);
    %     end
    %     fname_modelparameter = [str_pathbase_modelparameters,'\ModelParameter',str_fftsource,num2str(OutIndex)];
    %     save(fname_modelparameter,'SV_matlab','param','gamma','rho','feature_min','scalingFactors');
end

fprintf('All done!\n');
% param = GenerateArrInCsharp(param)
% feature_min = GenerateArrInCsharp(feature_min)
% scalingFactors = GenerateArrInCsharp(scalingFactors)

% DistributionOnFeature
% pause;
% FrameAndTestFiles