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
saveName = [timestamp,' Average CS summary','.xlsx'];
savePath = fullfile(saveDir,saveName);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cropLS = dir([dataDir,filesep,'*.mat']);

% Identify files by name ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
idxCropPerson = cellfun(@any,regexp({cropLS.name}','person','ignorecase'));
personLS = cropLS(idxCropPerson);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

for iFile = 1:numel(personLS)
    dataName = personLS(iFile).name;
    dataPath = fullfile(dataDir,dataName);
    
    sheet = regexprep(dataName,'\.mat','');
    
    load(dataPath);
    
    nObj = numel(objArray);
    h = waitbar(0,'Please wait. Analyzing data...');
    
    tb = array2table(nan(nObj,1));
    tb.Properties.VariableNames = {'mean_valid_CS'};
    tb.Properties.RowNames = {objArray.ID}';
    tb.Properties.DimensionNames{1} = ['file_',sheet];
    
    for iObj = 1:nObj
        obj = objArray(iObj);
        
        idxValid = obj.Observation & ~obj.InBed & obj.Compliance & ~obj.Error;
        
        tb.mean_valid_CS(iObj)  = mean(obj.CircadianStimulus(idxValid));
        
        waitbar(iObj/nObj);
    end
    writetable(tb,savePath,'Sheet',sheet,'WriteVariableNames',true,'WriteRowNames',true);
    close(h);
    
end

end

