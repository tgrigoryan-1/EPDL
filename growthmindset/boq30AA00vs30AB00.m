% Code for MAE30A B00 Winter 25 MAE30A vs MAE 30A A00 Winter 25 Independant T-test All Survey Questions
% The goal of this code is to analyze the baseline equivalence of both sections
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Because we have a mix of strings and int values for some of the columns
% We have to change how MATLAB reads this to not exclude any values
opts = detectImportOptions('MegaDataFile - MAE 30A A00 and B00 BOQ Survey.csv');
% Find columns whose names begin with the prefix (these are the ones that have a mix)
prefix = "UseTheScaleBelowToAnswerTheQuestion";
cols = startsWith(opts.VariableNames, prefix);
% Override ALL those columns to string type
opts = setvartype(opts, opts.VariableNames(cols), 'string');

% Setting up the data, filter based on A00 tag in second column
A00_data = readtable('MegaDataFile - MAE 30A A00 and B00 BOQ Survey',opts);
A00_data = A00_data(contains(A00_data{:,2},'A00'),:);
B00_data = readtable('MegaDataFile - MAE 30A A00 and B00 BOQ Survey',opts);
B00_data = B00_data(contains(B00_data{:,2},'B00'),:);

% Attention check questions
% Convert the attention-check responses to numbers
% First we have to define a convert function

% Define a convert function (updated from previous to handle string and non-string values)
% regexp is just a function in form regexp(text,pattern,match,once)
% The text is just any data that is fed into convert
% pattern is ^\s*\d+ which ^ means start, \s* means zero or more whitespace (spaces),\d+ means one or more digits
% match is just searching for a match within the pattern we just gave
% once is just taking the first iteration of this
convert = @(x) str2double( regexp(string(x), "^\s*\d+", "match", "once") );

% Now we can convert out attention checks
% A00
val18_A00 = convert(A00_data{:,18});
val29_A00 = convert(A00_data{:,29});
val43_A00 = convert(A00_data{:,43});
ac18_A00 = (val18_A00 == 5);
ac29_A00 = (val29_A00 == 1);
ac43_A00 = ismember(val43_A00,[1,2]);
attn_checked_A00 = ac18_A00 & ac29_A00 & ac43_A00; % Checks for students that answered all attention checks correctly
A00_data_fil = A00_data(attn_checked_A00, :);
% B00
val18_B00 = convert(B00_data{:,18});
val29_B00 = convert(B00_data{:,29});
val43_B00 = convert(B00_data{:,43});
ac18_B00 = (val18_B00 == 5);
ac29_B00 = (val29_B00 == 1);
ac43_B00 = ismember(val43_B00,[1,2]);
attn_checked_B00 = ac18_B00 & ac29_B00 & ac43_B00; % Checks for students that answered all attention checks correctly
B00_data_fil = B00_data(attn_checked_B00, :);

% Pulling all of the Questions (without the attention check)
A00_data_fil2 = A00_data_fil(:,[3:17,19:28,30:42,44:55,57:70]);
B00_data_fil2 = B00_data_fil(:,[3:17,19:28,30:42,44:55,57:70]);

% Dislike current variable names and decide to rename them
baseNames = ["Q" + (1:63), "PID"];

% Add prefix to differentiate
A00_Names = "A00_" + baseNames;
B00_Names = "B00_" + baseNames;

% Create new sets
A00_data_fil3 = A00_data_fil2;
B00_data_fil3 = B00_data_fil2;

% Append to sets
A00_data_fil3.Properties.VariableNames = A00_Names;
B00_data_fil3.Properties.VariableNames = B00_Names;

% Now we remove duplicates, use stable to keep order although won't really matter since we have to innerjoin
% For A00
[~, idx_A00] = unique(A00_data_fil3{:,64}, 'stable');
A00_data_unq = A00_data_fil3(idx_A00,:);
% For B00
[~, idx_B00] = unique(B00_data_fil3{:,64}, 'stable');
B00_data_unq = B00_data_fil3(idx_B00,:);

% We need to use the convert function again for all the data to get only the double values to run t-test
% --- Convert A00 data ---
varNamesA = A00_data_unq.Properties.VariableNames;
for i = 1:length(varNamesA)
    name = varNamesA{i};
    % Check for A00 prefix and ensure it's not the PID column
    if startsWith(name, "A00_") && ~endsWith(name, "PID")
        A00_data_unq.(name) = convert(A00_data_unq.(name));
    end
end

% --- Convert B00 data ---
varNamesB = B00_data_unq.Properties.VariableNames;
for i = 1:length(varNamesB)
    name = varNamesB{i};
    % Check for B00 prefix and ensure it's not the PID column
    if startsWith(name, "B00_") && ~endsWith(name, "PID")
        B00_data_unq.(name) = convert(B00_data_unq.(name));
    end
end

% Now we can run the Independant T-tests to determine baseline equivalence
% We preallocate a p value array
pvals = zeros(63,1);

% Run the t-test for all Questions
for k = 1:63
    prefA00 = "A00_Q" + k;
    prefB00 = "B00_Q" + k;

    A00Data = A00_data_unq.(prefA00);
    B00Data = B00_data_unq.(prefB00);

    [~, pvals(k)] = ttest2(A00Data, B00Data);
end

% We want to now pull the questions that correspond to significances
origNames = A00_data_fil2.Properties.VariableDescriptions;

for k = 1:63
    if pvals(k) <= 0.05
        prefA00 = "A00_Q" + k;
        prefB00 = "B00_Q" + k;

        A00Vec  = A00_data_unq.(prefA00);
        B00Vec  = B00_data_unq.(prefB00);
        meanA00 = mean(A00Vec, "omitnan");
        sdA00   = std(A00Vec, 0, "omitnan");   % sample SD
        meanB00 = mean(B00Vec, "omitnan");
        sdB00   = std(B00Vec, 0, "omitnan");   % sample SD
        nA00    = sum(~isnan(A00Vec));
        nB00    = sum(~isnan(B00Vec));
        meandiff = meanB00 - meanA00;
        if meandiff > 0
            meanind = "B00 > A00, increase";
        elseif meandiff < 0
            meanind = "B00 < A00, decrease";
        else
            meanind = "no mean difference";
        end

        % Retrieve the full question text by indexing
        fullQuestion = origNames{k};

        disp("-------------------------------------------------------------------------------------------------------------------------------")
        disp("Q" + k + " is significant with p = " + string(pvals(k)));
        disp("Full question text: " + fullQuestion)
        disp("Mean Difference (B00 - A00) = " + string(meandiff) + " -> " + meanind)
        % A00/B00 descriptive stats
        disp("nA00 = " + string(nA00))
        disp("nB00 = " + string(nB00))
        disp("A00: mean = " + string(meanA00) + ", SD = " + string(sdA00))
        disp("B00: mean = " + string(meanB00) + ", SD = " + string(sdB00))
    end
end