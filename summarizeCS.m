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
dwlGroup = {'401', '404', '406', '413', '415', '420', '423', '425', '426', '427', '428', '432', '433', '437', '441', '442', '445', '451', '453', '454', '457'}';
bwlGroup = {'402', '407', '409', '411', '414', '417', '418', '422', '424', '429', '434', '435', '436', '443', '444', '446', '448', '449', '452', '456'};

for iFile = 1:numel(personLS)
    dataName = personLS(iFile).name;
    dataPath = fullfile(dataDir,dataName);
    
    sheet = regexprep(dataName,'\.mat','');
    
    load(dataPath);
    
    nObj = numel(objArray);
    h = waitbar(0,'Please wait. Analyzing data...');
    
    tb = table;
    tb.condition = cell(nObj,1);
    tb.mean_valid_CS = nan(nObj,1);
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
        
        idxValid = obj.Observation & ~obj.InBed & obj.Compliance & ~obj.Error;
        
        tb.mean_valid_CS(iObj)  = mean(obj.CircadianStimulus(idxValid));
        
        if tb.mean_valid_CS(iObj) < 0.1
            tb.category{iObj} = 'CS < 0.1';
        elseif tb.mean_valid_CS(iObj) >= 0.1 && tb.mean_valid_CS(iObj) < 0.2
            tb.category{iObj} = ['0.1 ',char(8804),' CS < 0.2'];
        elseif tb.mean_valid_CS(iObj) >= 0.2 && tb.mean_valid_CS(iObj) < 0.3
            tb.category{iObj} = ['0.2 ',char(8804),' CS < 0.3'];
        elseif tb.mean_valid_CS(iObj) >= 0.3
            tb.category{iObj} = ['CS ',char(8805),' 0.3'];
        end
        
        waitbar(iObj/nObj);
    end
    writetable(tb,savePath,'Sheet',sheet,'WriteVariableNames',true,'WriteRowNames',true);
    close(h);
    
end

end

