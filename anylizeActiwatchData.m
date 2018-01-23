function anylizeActiwatchData
%ANYLIZEACTIWATCHDATA Summary of this function goes here
%   Detailed explanation goes here

% Enable dependencies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);


% Map paths
timestamp = datestr(now,'yyyy-mm-dd_HHMM');

projectDir = '\\root\projects\Acuity_MtSinai\Analyzed actiwatch data';

ls = dir([projectDir,filesep,'*.mat']);
[~,idxMostRecent] = max(vertcat(ls.datenum));
dataName = ls(idxMostRecent).name;
dataPath = fullfile(projectDir,dataName);

xlsxPath = fullfile(projectDir,[timestamp,'_ActiwatchAnalyses.xlsx']);


% Import source data
load(dataPath);


% Initialize output
T = table;
T.subject = vertcat({dataArray.subject})';
T.session = vertcat({dataArray.session})';
% Perform analysis
for iD = 1:numel(dataArray)
    % Extract data
    data    = dataArray(iD).data;
    idxKeep = data.Observation & data.Compliance;
    data    = data(idxKeep,:);
    % Shortcircuit if no useable data
    if isempty(data)
        warning(['Subject ',T.subject{iT},' ',T.session{iT},' is empty.'])
        continue
    end
    
    % Perform IS and IV analysis
    [IS_all, IV_all ] = isiv2(data.DateTime,          data.Activity         );
    
    % Perform cosinor analysis
    [~, ~, phi_all ] = phasor.cosinorfit(datenum(data.DateTime), data.Activity, 1, 1);
    % Convert radians to time of day
    acrophase_all  = duration(mod( phi_all,2*pi)*12/pi, 0, 0);
    
    % Find the number of days used
    nHours_all  = hours(numel(data.DateTime)*mode(diff(data.DateTime)));
    
    % Assign results to table
    T.nHours(iD)     = nHours_all;
    T.IS(iD)         = IS_all;
    T.IV(iD)         = IV_all;
    T.acrophase(iD)  = acrophase_all;
    
end % end of for

T = sortrows(T);

% Save results
writetable(T, xlsxPath);
winopen(xlsxPath);

end



