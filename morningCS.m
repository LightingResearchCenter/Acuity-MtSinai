function summarizeCS
%SUMMARIZECS Summary of this function goes here
%   Detailed explanation goes here

% Create timestamp ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
timestamp = datestr(now,'yyyy-mm-dd_HHMM');
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



% Enable dependencies ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[githubDir,~,~] = fileparts(pwd);
d12packDir = fullfile(githubDir,'d12pack');
addpath(d12packDir);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



% Map project folder paths ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if ispc
    projectDir = '\\root\projects\Acuity_MtSinai';
elseif ismac
    projectDir = '/Users/geoff/Desktop/Acuity MtSinai';
else
    error('Operating system is not supported')
end
dataDir  = fullfile(projectDir,'croppedData');
saveDir  = fullfile(projectDir,'tables');
saveName = [timestamp,' Morning CS','.xlsx'];
savePath = fullfile(saveDir,saveName);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cropLS = dir([dataDir,filesep,'*.mat']);

% Identify files by name ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
idxT3 = cellfun(@any,regexp({cropLS.name}','T3','ignorecase'));
dataLS = cropLS(idxT3);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

dwlGroup = {'401', '404', '406', '413', '415', '420', '423', '425', '426', '427', '428', '432', '433'}';
bwlGroup = {'402', '407', '409', '411', '414', '417', '418', '422', '424', '429', '434', '435', '436'};

for iFile = 1:numel(dataLS)
    dataName = dataLS(iFile).name;
    dataPath = fullfile(dataDir,dataName);
    
    sheet = regexprep(dataName,'\.mat','');
    
    load(dataPath);
    
    nObj = numel(objArray);
    h = waitbar(0,'Please wait. Analyzing data...');
    
    tb = table;
    tb.condition = cell(nObj,1);
    tb.morning_CS = nan(nObj,1);
    tb.category = cell(nObj,1);
    tb.Properties.RowNames = regexprep({objArray.ID}','(\d\d\d).*','$1');
    tb.Properties.DimensionNames{1} = ['file_',sheet];
    
    for iObj = 1:nObj
        obj = objArray(iObj);
        
        if ismember(tb.Properties.RowNames{iObj}, dwlGroup)
            tb.condition{iObj} = 'DWL';
        elseif ismember(tb.Properties.RowNames{iObj}, bwlGroup)
            tb.condition{iObj} = 'BWL';
        else
            tb.condition{iObj} = 'unknown';
        end
        
        if isa(obj,'d12pack.HumanData')
            idxValid = obj.Observation & ~obj.InBed & obj.Compliance & ~obj.Error;
        else
            idxValid = obj.Observation & ~obj.Error;
        end
        
        idx7 = hour(obj.Time) == 7;
        idx8 = hour(obj.Time) == 8;
        idx9 = hour(obj.Time) == 9;
        
        idx = idxValid & (idx7 | idx8 | idx9);
        
        tb.morning_CS(iObj) = mean(obj.CircadianStimulus(idx));
        
        if tb.morning_CS(iObj) < 0.1
            tb.category{iObj} = 'CS < 0.1';
        elseif tb.morning_CS(iObj) >= 0.1 && tb.morning_CS(iObj) < 0.2
            tb.category{iObj} = ['0.1 ',char(8804),' CS < 0.2'];
        elseif tb.morning_CS(iObj) >= 0.2 && tb.morning_CS(iObj) < 0.3
            tb.category{iObj} = ['0.2 ',char(8804),' CS < 0.3'];
        elseif tb.morning_CS(iObj) >= 0.3
            tb.category{iObj} = ['CS ',char(8805),' 0.3'];
        end
        
        
        waitbar(iObj/nObj);
    end
    writetable(tb,savePath,'Sheet',sheet,'WriteVariableNames',true,'WriteRowNames',true);
    close(h);
    
end

end

