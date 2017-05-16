function copyCrop
%COPYCROP Copy observation mask from person to static files
%   Copies person T3 observation to fixture and bed T3

[githubDir,~,~] = fileparts(pwd);
d12packDir = fullfile(githubDir,'d12pack');
addpath(d12packDir);

% Map data file paths
projectDir = '/Users/geoff/Desktop/Acuity MtSinai';
dataDir    = fullfile(projectDir,'CroppedData');
listing    = dir([dataDir,filesep,'*.mat']);

% Match file names
idxT3      = cellfun(@any,regexp({listing.name}','T3'));
idxPerson  = cellfun(@any,regexp({listing.name}','person','ignorecase'));
idxBed     = cellfun(@any,regexp({listing.name}','bed','ignorecase'));
idxFixture = cellfun(@any,regexp({listing.name}','fixture','ignorecase'));

personT3path  = fullfile(dataDir,listing(idxT3&idxPerson).name);
bedT3path     = fullfile(dataDir,listing(idxT3&idxBed).name);
fixtureT3path = fullfile(dataDir,listing(idxT3&idxFixture).name);

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
    bT3(iB).Observation = bT3(iB).Time >= t1 & bT3(iB).Time <= t2;
    fT3(iF).Observation = fT3(iF).Time >= t1 & fT3(iF).Time <= t2;
end

% Rename data and save to file
objArray = bT3;
save(bedT3path,'objArray');
objArray = fT3;
save(fixtureT3path,'objArray');

end

