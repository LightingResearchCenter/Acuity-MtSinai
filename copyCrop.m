function copyCrop
%COPYCROP Copy observation mask from person to static files
%   Copies person T3 observation to fixture and bed T3

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
% Check if project dir exists
if exist(projectDir,'dir') ~= 7
    error('Project dir does not exist');
end
convDir     = fullfile(projectDir,'convertedData');
cropDir     = fullfile(projectDir,'croppedData');
cropArchive = fullfile(cropDir,'archive');
% Make folders if they don't exist
folders = {convDir,cropDir,cropArchive};
for iDir = 1:numel(folders)
    if exist(folders{iDir},'dir') ~= 7
        mkdir(folders{iDir});
        warning([folders{iDir},' was created']);
    end
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



% Get folder listings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cropLS = dir([cropDir,filesep,'*.mat']);
convLS = dir([convDir,filesep,'*.mat']);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Compare file names ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if ~ all(ismember({convLS.name},{cropLS.name}))
    % Move cropped files to archive .......................................
    for iCrop = 1:numel(cropLS)
        thisSource = fullfile(cropDir,cropLS(iCrop).name);
        thisDestination = fullfile(cropArchive,cropLS(iCrop).name);
        movefile(thisSource, thisDestination);
    end
    % .....................................................................
    
    % Copy converted files to crop dir ....................................
    for iConv = 1:numel(convLS)
        thisSource = fullfile(convDir,convLS(iConv).name);
        thisDestination = fullfile(cropDir,convLS(iConv).name);
        copyfile(thisSource, thisDestination);
    end
    % .....................................................................
    
    % Get new folder listings .............................................
    cropLS = dir([cropDir,filesep,'*.mat']);
    archLS = dir([cropArchive,filesep,'*.mat']);
    % .....................................................................
    
    % Identify files by name ..............................................
    idxCropPerson = cellfun(@any,regexp({cropLS.name}','person','ignorecase'));
    idxArchPerson = cellfun(@any,regexp({archLS.name}','person','ignorecase'));
    
    idxCropT1 = cellfun(@any,regexp({cropLS.name}','T1'));
    idxCropT3 = cellfun(@any,regexp({cropLS.name}','T3'));
    
    idxArchT1 = cellfun(@any,regexp({archLS.name}','T1'));
    idxArchT3 = cellfun(@any,regexp({archLS.name}','T3'));
    
    idxCropPersonT1 = idxCropPerson & idxCropT1;
    idxCropPersonT3 = idxCropPerson & idxCropT3;
    idxArchPersonT1 = idxArchPerson & idxArchT1;
    idxArchPersonT3 = idxArchPerson & idxArchT3;
    % .....................................................................
    
    % Identify which files are most recent ................................
    cropPersonT1LS = cropLS(idxCropPersonT1);
    cropPersonT3LS = cropLS(idxCropPersonT3);
    archPersonT1LS = archLS(idxArchPersonT1);
    archPersonT3LS = archLS(idxArchPersonT3);
    
    [~,idxMax] = max([cropPersonT1LS.datenum]);
    newPersonT1Path = fullfile(cropDir,cropPersonT1LS(idxMax).name);
    [~,idxMax] = max([cropPersonT3LS.datenum]);
    newPersonT3Path = fullfile(cropDir,cropPersonT3LS(idxMax).name);
    [~,idxMax] = max([archPersonT1LS.datenum]);
    prevPersonT1Path = fullfile(cropArchive,archPersonT1LS(idxMax).name);
    [~,idxMax] = max([archPersonT3LS.datenum]);
    prevPersonT3Path = fullfile(cropArchive,archPersonT3LS(idxMax).name);
    % .....................................................................
    
    % Copy previous person croppings to new person files ..................
    % T1 ..................................................................
    if exist(newPersonT1Path,'file') == 2 && exist(prevPersonT1Path,'file') == 2
        copyHumanCrops(newPersonT1Path, prevPersonT1Path);
    end
    % T3 ..................................................................
    if exist(newPersonT3Path,'file') == 2 && exist(prevPersonT3Path,'file') == 2
        copyHumanCrops(newPersonT3Path, prevPersonT3Path);
    end
    % .....................................................................
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

listing = dir([cropDir,filesep,'*.mat']);

% Match file names
idxT3      = cellfun(@any,regexp({listing.name}','T3'));
idxPerson  = cellfun(@any,regexp({listing.name}','person','ignorecase'));
idxBed     = cellfun(@any,regexp({listing.name}','bed','ignorecase'));
idxFixture = cellfun(@any,regexp({listing.name}','fixture','ignorecase'));

personT3path  = fullfile(cropDir,listing(idxT3&idxPerson).name);
bedT3path     = fullfile(cropDir,listing(idxT3&idxBed).name);
fixtureT3path = fullfile(cropDir,listing(idxT3&idxFixture).name);

% Load data
pT3temp = load(personT3path);
bT3temp = load(bedT3path);
fT3temp = load(fixtureT3path);

pFns = fieldnames(pT3temp);
bFns = fieldnames(bT3temp);
fFns = fieldnames(fT3temp);

pT3 = pT3temp.(pFns{1});
bT3 = bT3temp.(bFns{1});
fT3 = fT3temp.(fFns{1});

% Extract IDs
pIDs = {pT3.ID}';
bIDs = {bT3.ID}';
fIDs = {fT3.ID}';

% Iterate through person data
for iP = 1:numel(pT3)
    % Find matching IDs
    thisPID = pIDs{iP};
    thisBID = [thisPID,'-bed'];
    thisFID = [thisPID,'-fixture'];
    
    iB = strcmp(thisBID,bIDs);
    iF = strcmp(thisFID,fIDs);
    
    % Extract observation extent
    t1 = min(pT3(iP).Time(pT3(iP).Observation));
    t2 = max(pT3(iP).Time(pT3(iP).Observation));
    
    % Copy observation over to bed and fixture
    if any(iB)
    bT3(iB).Observation = bT3(iB).Time >= t1 & bT3(iB).Time <= t2;
    end
    if any(iF)
    fT3(iF).Observation = fT3(iF).Time >= t1 & fT3(iF).Time <= t2;
    end
end

% Rename data and save to file
objArray = bT3;
save(bedT3path,'objArray');
objArray = fT3;
save(fixtureT3path,'objArray');

end



function copyHumanCrops(newPath, prevPath)
% Load data
tempNew  = load(newPath);
tempPrev = load(prevPath);
fnNew  = fieldnames(tempNew);
fnPrev = fieldnames(tempPrev);
objArray = tempNew.(fnNew{1});
prevObjArray = tempPrev.(fnPrev{1});

% Extract IDs
newIDs  = {objArray.ID}';
prevIDs = {prevObjArray.ID}';

% Iterate through subjects
for iSub = 1:numel(newIDs)
    [Lia,Locb] = ismember(newIDs{iSub},prevIDs);
    if Lia
        % Copy observation
        objArray(iSub).Observation = prevObjArray(Locb).Observation;
        % Copy error
        objArray(iSub).Error = prevObjArray(Locb).Error;
        % Copy compliance
        objArray(iSub).Compliance = prevObjArray(Locb).Compliance;
        % Copy bed log
        objArray(iSub).BedLog = prevObjArray(Locb).BedLog;
    end
end

% Save modified data
save(newPath,'objArray');

end