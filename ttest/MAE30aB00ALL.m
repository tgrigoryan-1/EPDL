% Code for MAE30A Winter 25 T-test All Survey Questions B00
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

opts2 = detectImportOptions('MegaDataFile - MAE30A EOQ Survey');
% Find columns whose names begin with the prefix
prefix2 = "UseTheScaleBelowToAnswerTheQuestion";
cols2 = startsWith(opts2.VariableNames, prefix2);
% Override ALL those columns to string type
opts2 = setvartype(opts2, opts2.VariableNames(cols2), 'string');

% Setting up the data, filter based on A00 tag in second column
boq_data = readtable('MegaDataFile - MAE 30A A00 and B00 BOQ Survey',opts);
eoq_data = readtable('MegaDataFile - MAE30A EOQ Survey',opts2);
boq_data_fil = boq_data(contains(boq_data{:,2},'B00'),:);
eoq_data_fil = eoq_data(contains(eoq_data{:,2},'B00'),:);

% Attention check questions
% For BOQ
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
val18_boq = convert(boq_data_fil{:,18});
val29_boq = convert(boq_data_fil{:,29});
val43_boq = convert(boq_data_fil{:,43});
ac18_boq = (val18_boq == 5);
ac29_boq = (val29_boq == 1);
ac43_boq = ismember(val43_boq,[1,2]);
attn_checked_boq = ac18_boq & ac29_boq & ac43_boq; % Checks for students that answered all attention checks correctly
boq_data_fil = boq_data_fil(attn_checked_boq, :);

% For EOQ
% Convert the attention-check responses to numeric
val18_eoq = convert(eoq_data_fil{:,18});
val29_eoq = convert(eoq_data_fil{:,29});
val43_eoq = convert(eoq_data_fil{:,43});
ac18_eoq = (val18_eoq == 5);
ac29_eoq = (val29_eoq == 1);
ac43_eoq = (val43_eoq == 1);
attn_checked_eoq = ac18_eoq & ac29_eoq & ac43_eoq; % Checks for students that answered all attention checks correctly
eoq_data_fil = eoq_data_fil(attn_checked_eoq, :);


% Pulling all of the Questions (without the attention check)
boq_data_fil2 = boq_data_fil(:,[3:17,19:28,30:42,44:55,57:69,70]);
eoq_data_fil2 = eoq_data_fil(:,[3:17,19:28,30:42,44:55,57:69,126]);

% Dislike current variable names and decide to rename them
baseNames = ["Q" + (1:63), "PID"];

% Add prefix to differentiate
boq_Names = "BOQ_" + baseNames;
eoq_Names = "EOQ_" + baseNames;

% Create new sets
boq_data_fil3 = boq_data_fil2;
eoq_data_fil3 = eoq_data_fil2;

% Append to sets
boq_data_fil3.Properties.VariableNames = boq_Names;
eoq_data_fil3.Properties.VariableNames = eoq_Names;

% Now we remove duplicates, use stable to keep order although won't really matter since we have to innerjoin
% For boq
[~, idx_boq] = unique(boq_data_fil3{:,64}, 'stable');
boq_data_unq = boq_data_fil3(idx_boq,:);
% For eoq
[~, idx_eoq] = unique(eoq_data_fil3{:,64},'stable');
eoq_data_unq = eoq_data_fil3(idx_eoq,:);

% Now to use innerjoin to weed out anyone that isn't on both lists, since I named them different I have to use Left and Right Keys
fullsetfil = innerjoin(boq_data_unq,eoq_data_unq,'LeftKeys','BOQ_PID','RightKeys','EOQ_PID');

% We need to use the convert function again for all the data to get only the double values to run t-test
varNames = fullsetfil.Properties.VariableNames;
for i = 1:length(varNames)
	name = varNames{i};
	if (startsWith(name,"BOQ_") || startsWith(name,"EOQ_")) && ~endsWith(name, "PID")
		fullsetfil.(name) = convert(fullsetfil.(name));
	end
end

% Now we can run the tests
% We preallocate a p value array
pvals = zeros(63,1);

% Run the t-test for all Questions
for k = 1:63
    prefBOQ = "BOQ_Q" + k;
    prefEOQ = "EOQ_Q" + k;

    boqData = fullsetfil.(prefBOQ);
    eoqData = fullsetfil.(prefEOQ);

    [~, pvals(k)] = ttest(boqData, eoqData);
end

% We want to now pull the questions that correspond to significances
origNames = boq_data_fil2.Properties.VariableDescriptions;

for k = 1:63
    if pvals(k) <= 0.05
        prefBOQ = "BOQ_Q" + k;
        prefEOQ = "EOQ_Q" + k;
        meandiff = mean(fullsetfil.(prefEOQ)) - mean(fullsetfil.(prefBOQ));
        if meandiff > 0
            meanind = "EOQ > BOQ, increase";
        elseif meandiff < 0
            meanind = "EOQ < BOQ, decrease";
        else
            meanind = "no mean difference";
        end

        % Retrieve the full question text by indexing
        fullQuestion = origNames{k};

        disp("-------------------------------------------------------------------------------------------------------------------------------")
        disp("Q" + k + " is significant with p = " + string(pvals(k)));
        disp("Full question text: " + fullQuestion)
        disp("Mean Difference (EOQ - BOQ) = " + string(meandiff) + " -> " + meanind)
    end
end

% Also check the growth mindset questions, specifically their mean differences
for k = 53:55
    prefBOQ = "BOQ_Q" + k;
    prefEOQ = "EOQ_Q" + k;
    meandiff = mean(fullsetfil.(prefEOQ)) - mean(fullsetfil.(prefBOQ));
    if meandiff > 0
        meanind = "EOQ > BOQ, increase";
    elseif meandiff < 0
        meanind = "EOQ < BOQ, decrease";
    else
        meanind = "no mean difference";
    end
    disp("-------------------------------------------------------------------------------------------------------------------------------")
    disp("For growth mindset questions: " + origNames{k})
    disp("Mean Difference (EOQ - BOQ) = " + string(meandiff) + " -> " + meanind)
end

% Average out the growth mindset questions
% 53,54,55 are the growth mindset questions
growthMindsetVecBOQ = fullsetfil.BOQ_Q53 + fullsetfil.BOQ_Q54 + fullsetfil.BOQ_Q55;
growthMindsetVecEOQ = fullsetfil.EOQ_Q53 + fullsetfil.EOQ_Q54 + fullsetfil.EOQ_Q55;
[~, pvalgrowth] = ttest(growthMindsetVecBOQ, growthMindsetVecEOQ);
meandiff = mean(growthMindsetVecEOQ) - mean(growthMindsetVecBOQ);
if meandiff > 0
    meanind = "EOQ > BOQ, increase";
elseif meandiff < 0
    meanind = "EOQ < BOQ, decrease";
else
    meanind = "no mean difference";
end
meandiff = mean(growthMindsetVecEOQ) - mean(growthMindsetVecBOQ);
disp("-------------------------------------------------------------------------------------------------------------------------------")
if pvalgrowth <= 0.05
    disp("Growth Mindset Question Average is significant with p = " + string(pvalgrowth));
else
    disp("Growth Mindset Question Average is not significant with p = " + string(pvalgrowth));
end
disp("Mean Difference (EOQ - BOQ) = " + string(meandiff) + " -> " + meanind);

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL\ttest')