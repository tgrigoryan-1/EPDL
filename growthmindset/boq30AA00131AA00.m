% Code for MAE30A A00 Winter 25 BOQ vs MAE131A A00 Spring 25 T-test All Survey Questions
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

opts2 = detectImportOptions('MegaDataFile - MAE131A BOQ Survey');
% Find columns whose names begin with the prefix
prefix2 = "UseTheScaleBelowToAnswerTheQuestion";
cols2 = startsWith(opts2.VariableNames, prefix2);
% Override ALL those columns to string type
opts2 = setvartype(opts2, opts2.VariableNames(cols2), 'string');

% Setting up the data, filter based on A00 tag in second column
MAE30A_data = readtable('MegaDataFile - MAE 30A A00 and B00 BOQ Survey',opts);
MAE30A_data = MAE30A_data(contains(MAE30A_data{:,2},'A00'),:);
MAE131A_data = readtable('MegaDataFile - MAE131A BOQ Survey',opts2);

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
val18_MAE30A = convert(MAE30A_data{:,18});
val29_MAE30A = convert(MAE30A_data{:,29});
val43_MAE30A = convert(MAE30A_data{:,43});
ac18_MAE30A = (val18_MAE30A == 5);
ac29_MAE30A = (val29_MAE30A == 1);
ac43_MAE30A = ismember(val43_MAE30A,[1,2]);
attn_checked_MAE30A = ac18_MAE30A & ac29_MAE30A & ac43_MAE30A; % Checks for students that answered all attention checks correctly
MAE30A_data_fil = MAE30A_data(attn_checked_MAE30A, :);

% For MAE131A
% Convert the attention-check responses to numeric
val18_MAE131A = convert(MAE131A_data{:,17});
val29_MAE131A = convert(MAE131A_data{:,28});
val43_MAE131A = convert(MAE131A_data{:,42});
ac18_MAE131A = (val18_MAE131A == 5);
ac29_MAE131A = (val29_MAE131A == 1);
ac43_MAE131A = (val43_MAE131A == 2);
attn_checked_MAE131A = ac18_MAE131A & ac29_MAE131A & ac43_MAE131A; % Checks for students that answered all attention checks correctly
MAE131A_data_fil = MAE131A_data(attn_checked_MAE131A, :);


% Pulling all of the Questions (without the attention check)
MAE30A_data_fil2 = MAE30A_data_fil(:,[3:17,19:28,30:42,44:55,57:70]);
MAE131A_data_fil2 = MAE131A_data_fil(:,[3:16,17:27,29:41,43:54,56:69,]);

% Dislike current variable names and decide to rename them
baseNames = ["Q" + (1:63), "PID"];

% Add prefix to differentiate
MAE30A_Names = "MAE30A_" + baseNames;
MAE131A_Names = "MAE131A_" + baseNames;

% Create new sets
MAE30A_data_fil3 = MAE30A_data_fil2
MAE131A_data_fil3 = MAE131A_data_fil2

% Append to sets
MAE30A_data_fil3.Properties.VariableNames = MAE30A_Names;
MAE131A_data_fil3.Properties.VariableNames = MAE131A_Names;

% Now we remove duplicates, use stable to keep order although won't really matter since we have to innerjoin
% For MAE30A
[~, idx_MAE30A] = unique(MAE30A_data_fil3{:,64}, 'stable');
MAE30A_data_unq = MAE30A_data_fil3(idx_MAE30A,:);
% For MAE131A
[~, idx_MAE131A] = unique(MAE131A_data_fil3{:,64},'stable');
MAE131A_data_unq = MAE131A_data_fil3(idx_MAE131A,:);

% Now to use innerjoin to weed out anyone that isn't on both lists, since I named them different I have to use Left and Right Keys
fullsetfil = innerjoin(MAE30A_data_unq,MAE131A_data_unq,'LeftKeys','MAE30A_PID','RightKeys','MAE131A_PID')

% We need to use the convert function again for all the data to get only the double values to run t-test
varNames = fullsetfil.Properties.VariableNames;
for i = 1:length(varNames)
    name = varNames{i};
    if (startsWith(name,"MAE30A_") || startsWith(name,"MAE131A_")) && ~endsWith(name, "PID")
        fullsetfil.(name) = convert(fullsetfil.(name));
    end
end

% Now we can run the tests
% We preallocate a p value array
pvals = zeros(63,1);

% Run the t-test for all Questions
for k = 1:63
    prefMAE30A = "MAE30A_Q" + k;
    prefMAE131A = "MAE131A_Q" + k;

    MAE30AData = fullsetfil.(prefMAE30A);
    MAE131AData = fullsetfil.(prefMAE131A);

    [~, pvals(k)] = ttest(MAE30AData, MAE131AData);
end

% We want to now pull the questions that correspond to significances
origNames = MAE30A_data_fil2.Properties.VariableDescriptions;

for k = 1:63
    if pvals(k) <= 0.05
        prefMAE30A = "MAE30A_Q" + k;
        prefMAE131A = "MAE131A_Q" + k;
        meandiff = mean(fullsetfil.(prefMAE131A)) - mean(fullsetfil.(prefMAE30A));
        if meandiff > 0
            meanind = "MAE131A > MAE30A, increase";
        elseif meandiff < 0
            meanind = "MAE131A < MAE30A, decrease";
        else
            meanind = "no mean difference";
        end

        % Retrieve the full question text by indexing
        fullQuestion = origNames{k};

        disp("-------------------------------------------------------------------------------------------------------------------------------")
        disp("Q" + k + " is significant with p = " + string(pvals(k)));
        disp("Full question text: " + fullQuestion)
        disp("Mean Difference (MAE131A - MAE30A) = " + string(meandiff) + " -> " + meanind)
    end
end

% Also check the growth mindset questions, specifically their mean differences
for k = 53:55
    prefMAE30A = "MAE30A_Q" + k;
    prefMAE131A = "MAE131A_Q" + k;
    meandiff = mean(fullsetfil.(prefMAE131A)) - mean(fullsetfil.(prefMAE30A));
    if meandiff > 0
        meanind = "MAE131A > MAE30A, increase";
    elseif meandiff < 0
        meanind = "MAE131A < MAE30A, decrease";
    else
        meanind = "no mean difference";
    end
    disp("-------------------------------------------------------------------------------------------------------------------------------")
    disp("For growth mindset questions: " + origNames{k})
    disp("Mean Difference (MAE131A - MAE30A) = " + string(meandiff) + " -> " + meanind)
end

% Average out the growth mindset questions
% 53,54,55 are the growth mindset questions
growthMindsetVecMAE30A = fullsetfil.MAE30A_Q53 + fullsetfil.MAE30A_Q54 + fullsetfil.MAE30A_Q55;
growthMindsetVecMAE131A = fullsetfil.MAE131A_Q53 + fullsetfil.MAE131A_Q54 + fullsetfil.MAE131A_Q55;
[~, pvalgrowth] = ttest(growthMindsetVecMAE30A, growthMindsetVecMAE131A);
meandiff = mean(growthMindsetVecMAE131A) - mean(growthMindsetVecMAE30A);
if meandiff > 0
    meanind = "MAE131A > MAE30A, increase";
elseif meandiff < 0
    meanind = "MAE131A < MAE30A, decrease";
else
    meanind = "no mean difference";
end
meandiff = mean(growthMindsetVecMAE131A) - mean(growthMindsetVecMAE30A);
disp("-------------------------------------------------------------------------------------------------------------------------------")
if pvalgrowth <= 0.05
    disp("Growth Mindset Question Average is significant with p = " + string(pvalgrowth));
else
    disp("Growth Mindset Question Average is not significant with p = " + string(pvalgrowth));
end
disp("Mean Difference (MAE131A - MAE30A) = " + string(meandiff) + " -> " + meanind);

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL\growthmindset')