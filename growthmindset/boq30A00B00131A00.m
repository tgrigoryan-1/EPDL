% Code for MAE30A B00 Winter 25 MAE30A vs MAE 30A A00 Winter 25 Independant T-test All Survey Questions
% The goal of this code is to analyze the baseline equivalence of both sections with regard to students who took MAE 131A Spring 25
cd('C:\Users\tigrr\Downloads')
close all, clear, clc

% --- Import Options ---
opts = detectImportOptions('MegaDataFile - MAE 30A A00 and B00 BOQ Survey.csv');
prefix = "UseTheScaleBelowToAnswerTheQuestion";
cols = startsWith(opts.VariableNames, prefix);
opts = setvartype(opts, opts.VariableNames(cols), 'string');

opts2 = detectImportOptions('MegaDataFile - MAE131A BOQ Survey');
prefix2 = "UseTheScaleBelowToAnswerTheQuestion";
cols2 = startsWith(opts2.VariableNames, prefix2);
opts2 = setvartype(opts2, opts2.VariableNames(cols2), 'string');

% Load the full data (Do not filter by A00/B00 yet)
MAE30A_data = readtable('MegaDataFile - MAE 30A A00 and B00 BOQ Survey.csv', opts);
MAE131A_data = readtable('MegaDataFile - MAE131A BOQ Survey', opts2);

% --- Attention Checks ---
convert = @(x) str2double( regexp(string(x), "^\s*\d+", "match", "once") );

% MAE30A
val18_MAE30A = convert(MAE30A_data{:,18});
val29_MAE30A = convert(MAE30A_data{:,29});
val43_MAE30A = convert(MAE30A_data{:,43});
ac18_MAE30A = (val18_MAE30A == 5);
ac29_MAE30A = (val29_MAE30A == 1);
ac43_MAE30A = ismember(val43_MAE30A,[1,2]);
attn_checked_MAE30A = ac18_MAE30A & ac29_MAE30A & ac43_MAE30A; 
MAE30A_data_fil = MAE30A_data(attn_checked_MAE30A, :);

% MAE131A
val18_MAE131A = convert(MAE131A_data{:,17});
val29_MAE131A = convert(MAE131A_data{:,28});
val43_MAE131A = convert(MAE131A_data{:,42});
ac18_MAE131A = (val18_MAE131A == 5);
ac29_MAE131A = (val29_MAE131A == 1);
ac43_MAE131A = (val43_MAE131A == 2);
attn_checked_MAE131A = ac18_MAE131A & ac29_MAE131A & ac43_MAE131A; 
MAE131A_data_fil = MAE131A_data(attn_checked_MAE131A, :);

% IMPORTANT: We are now pulling Column 2 (Section) for MAE30A as well in order to split later
MAE30A_data_fil2 = MAE30A_data_fil(:,[2:17,19:28,30:42,44:55,57:70]); 
MAE131A_data_fil2 = MAE131A_data_fil(:,[2:16,18:27,29:41,43:54,56:69]);

% Adjust names to account for the extra "Section" column in 30A
baseNames30A = ["Section", "Q" + (1:63), "PID"];
baseNames131A = ["Q" + (1:63), "PID"];

MAE30A_data_fil3 = MAE30A_data_fil2;
MAE131A_data_fil3 = MAE131A_data_fil2;

MAE30A_data_fil3.Properties.VariableNames = "MAE30A_" + baseNames30A;
MAE131A_data_fil3.Properties.VariableNames = "MAE131A_" + baseNames131A;

% --- Remove Duplicates ---
[~, idx_MAE30A] = unique(MAE30A_data_fil3.MAE30A_PID, 'stable');
MAE30A_data_unq = MAE30A_data_fil3(idx_MAE30A,:);

[~, idx_MAE131A] = unique(MAE131A_data_fil3.MAE131A_PID,'stable');
MAE131A_data_unq = MAE131A_data_fil3(idx_MAE131A,:);

% --- Innerjoin to filter for students in BOTH classes ---
% The innerjoin will automatically retain the "MAE30A_Section" column 
fullsetfil = innerjoin(MAE30A_data_unq, MAE131A_data_unq, 'LeftKeys', 'MAE30A_PID', 'RightKeys', 'MAE131A_PID');

% --- Convert Strings to Doubles for the questions ---
varNames = fullsetfil.Properties.VariableNames;
for i = 1:length(varNames)
    name = varNames{i};
    % Make sure we do not try to convert the Section column or the PIDs
    if (startsWith(name,"MAE30A_Q") || startsWith(name,"MAE131A_Q"))
        fullsetfil.(name) = convert(fullsetfil.(name));
    end
end

% --- SPLIT INTO A00 AND B00 ---
% Now that we have perfectly filtered for students who took 131A, we split them based on their 30A section
A00_data = fullsetfil(contains(fullsetfil.MAE30A_Section, 'A00'), :);
B00_data = fullsetfil(contains(fullsetfil.MAE30A_Section, 'B00'), :);

% --- Run Independent T-Tests (A00 vs B00 Baseline Equivalence) ---
pvals = zeros(63,1);
origNames = MAE30A_data.Properties.VariableDescriptions;

for k = 1:63
    prefMAE30A = "MAE30A_Q" + k;

    % Pull the specific question for A00 and B00
    A00Data = A00_data.(prefMAE30A);
    B00Data = B00_data.(prefMAE30A);

    % Use ttest2 for independent samples (A00 vs B00)
    [~, pvals(k)] = ttest2(A00Data, B00Data);
    
    if pvals(k) <= 0.05
        meanA00 = mean(A00Data, "omitnan");
        sdA00   = std(A00Data, 0, "omitnan");   
        meanB00 = mean(B00Data, "omitnan");
        sdB00   = std(B00Data, 0, "omitnan");   
        
        nA00    = sum(~isnan(A00Data));
        nB00    = sum(~isnan(B00Data));

        meandiff = meanB00 - meanA00;
        
        if meandiff > 0
            meanind = "B00 > A00, increase";
        elseif meandiff < 0
            meanind = "B00 < A00, decrease";
        else
            meanind = "no mean difference";
        end

        disp("-------------------------------------------------------------------------------------------------------------------------------")
        disp("Q" + k + " is significant with p = " + string(pvals(k)));
        if ~isempty(origNames) && length(origNames) >= (k+2) % +2 offset for the columns we kept
             disp("Full question text: " + origNames{k+2})
        end
        disp("Mean Difference (B00 - A00) = " + string(meandiff) + " -> " + meanind)
        disp("nA00 = " + string(nA00) + " | nB00 = " + string(nB00))
        disp("A00: mean = " + string(meanA00) + ", SD = " + string(sdA00))
        disp("B00: mean = " + string(meanB00) + ", SD = " + string(sdB00))
    end
end
cd('C:\Users\tigrr\UCSD\EPDL\growthmindset')