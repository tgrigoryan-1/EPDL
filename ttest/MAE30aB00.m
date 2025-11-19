% Code for MAE30A Winter 25 T-test Frequency of Active Learning Techniques B00
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Setting up the data, filter based on B00 tag in second column
boq_data = readtable('MegaDataFile - MAE 30A A00 and B00 BOQ Survey');
eoq_data = readtable('MegaDataFile - MAE30A EOQ Survey');
boq_data_fil = boq_data(contains(boq_data{:,2},'B00'),:);
eoq_data_fil = eoq_data(contains(eoq_data{:,2},'B00'),:);

% Attention check questions
% For BOQ
% Convert the attention-check responses to numbers
% First we have to define a convert function
% Converter for Likert responses ~ '5 (Almost Always)'
convert = @(x) str2double(extractBefore(string(x), " ")); % Takes the first value and converts it to a double
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


% Pulling all of the "Rate your frequency" Questions (without the attention check)
boq_data_fil2 = boq_data_fil(:,[33:42,44:55, 70]);
eoq_data_fil2 = eoq_data_fil(:,[33:42,44:55, 126]);

% Dislike current variable names and decide to rename them
baseNames = ["Q1","Q2","Q3","Q4","Q5","Q6","Q7","Q8","Q9","Q10","Q11","Q12","Q13","Q14","Q15","Q16","Q17","Q18","Q19","Q20","Q21","Q22","PID"];

% Add prefix to differentiate
boq_Names = "BOQ_" + baseNames;
eoq_Names = "EOQ_" + baseNames;

% Append to sets
boq_data_fil2.Properties.VariableNames = boq_Names;
eoq_data_fil2.Properties.VariableNames = eoq_Names;

% Now we remove duplicates, use stable to keep order although won't really matter since we have to innerjoin
% For boq
[~, idx_boq] = unique(boq_data_fil2{:,23}, 'stable');
boq_data_unq = boq_data_fil2(idx_boq,:);
% For eoq
[~, idx_eoq] = unique(eoq_data_fil2{:,23},'stable');
eoq_data_unq = eoq_data_fil2(idx_eoq,:);

% Now to use innerjoin to weed out anyone that isn't on both lists, since I named them different I have to use Left and Right Keys
fullsetfil = innerjoin(boq_data_unq,eoq_data_unq,'LeftKeys','BOQ_PID','RightKeys','EOQ_PID');

% We need to use the convert function again for all the data to get only the double values to run t-test
varNames = fullsetfil.Properties.VariableNames;
for i = 1:length(varNames)
	name = varNames{i};
	if startsWith(name,"BOQ_") || startsWith(name,"EOQ_") && ~endsWith(name, "PID")
		fullsetfil.(name) = convert(fullsetfil.(name));
	end
end

% Now we can run the tests

% Q1
% "Rate the frequency which which you use the following learning techniques. 
% [Rereading slides, lecture notes, textbook, or class materials; rewatching lecture recordings]"
[~,pQ1] = ttest(fullsetfil.BOQ_Q1,fullsetfil.EOQ_Q1)

% Q2
% "Rate the frequency which which you use the following learning techniques.
% [Rewriting Notes]"
[~,pQ2] = ttest(fullsetfil.BOQ_Q2,fullsetfil.EOQ_Q2)

% Q3
% "Rate the frequency which which you use the following learning techniques.
% [Highlighting or underlining notes or textbook]"
[~,pQ3] = ttest(fullsetfil.BOQ_Q3,fullsetfil.EOQ_Q3)

% Q4
% "Rate the frequency which which you use the following learning techniques.
% [Taking verbatim (word-for-word) notes during lecture]"
[~,pQ4] = ttest(fullsetfil.BOQ_Q4,fullsetfil.EOQ_Q4)

% Q5
% "Rate the frequency which which you use the following learning techniques.
% [Review problem solutions]"
[~,pQ5] = ttest(fullsetfil.BOQ_Q5,fullsetfil.EOQ_Q5)

% Q6
% "Rate the frequency which which you use the following learning techniques.
% [Summarizing or outlining]"
[~,pQ6] = ttest(fullsetfil.BOQ_Q6,fullsetfil.EOQ_Q6)

% Q7
% "Rate the frequency which which you use the following learning techniques.
% [Imagery: Forming mental images of text materials while reading or listening]"
[~,pQ7] = ttest(fullsetfil.BOQ_Q7,fullsetfil.EOQ_Q7)

% Q8
% "Rate the frequency which which you use the following learning techniques.
% [Think of real-life examples]"
[~,pQ8] = ttest(fullsetfil.BOQ_Q8,fullsetfil.EOQ_Q8)

% Q9
% "Rate the frequency which which you use the following learning techniques.
% [Concept/mind mapping: organize knowledge graphically, with connections between concepts]"
[~,pQ9] = ttest(fullsetfil.BOQ_Q9,fullsetfil.EOQ_Q9)

% Q10
% "Rate the frequency which which you use the following learning techniques.
% [Active recall: Trying to remember as much from class as I can without looking]"
[~,pQ10] = ttest(fullsetfil.BOQ_Q10,fullsetfil.EOQ_Q10)

% Q11
% "Rate the frequency which which you use the following learning techniques.
% [Self-testing: Using practice questions, flashcards, or otherwise testing myself]"
[~,pQ11] = ttest(fullsetfil.BOQ_Q11,fullsetfil.EOQ_Q11)

% Q12
% "Rate the frequency which which you use the following learning techniques.
% [Self-explanation/elaboration: Answering questions like "How does this fit with what I already know?"; "Why is this true?"; "What underlying principles apply to this problem-solving process?"]"
[~,pQ12] = ttest(fullsetfil.BOQ_Q12,fullsetfil.EOQ_Q12)

% Q13
% "Rate the frequency which which you use the following learning techniques.
% [Teaching or explaining to others]"
[~,pQ13] = ttest(fullsetfil.BOQ_Q13,fullsetfil.EOQ_Q13)

% Q14
% "Rate the frequency which which you use the following learning techniques.
% [Mnemonic strategies: Using imagery links and acronyms for memorization]"
[~,pQ14] = ttest(fullsetfil.BOQ_Q14,fullsetfil.EOQ_Q14)

% Q15
% "Rate the frequency which which you use the following learning techniques.
% [Using feedback on graded work to target my studying]"
[~,pQ15] = ttest(fullsetfil.BOQ_Q15,fullsetfil.EOQ_Q15)

% Q16
% "Rate the frequency which which you use the following learning techniques.
% [Spreading out studying for exams across time (1: Only studying right before exam; 5: Even distribution of studying over time)]"
[~,pQ16] = ttest(fullsetfil.BOQ_Q16,fullsetfil.EOQ_Q16)

% Q17
% "Rate the frequency which which you use the following learning techniques.
% [Interleaving: practice alternating between different concepts]"
[~,pQ17] = ttest(fullsetfil.BOQ_Q17,fullsetfil.EOQ_Q17)

% Q18
% "Rate the frequency which which you use the following learning techniques.
% [Self-care: Maintaing personal well-being (sleep, food) as part of your learning strategy]"
[~,pQ18] = ttest(fullsetfil.BOQ_Q18,fullsetfil.EOQ_Q18)

% Q19
% "Rate the frequency which which you use the following learning techniques.
% [Plan your study time in advance]"
[~,pQ19] = ttest(fullsetfil.BOQ_Q19,fullsetfil.EOQ_Q19)

% Q20
% "Rate the frequency which which you use the following learning techniques.
% [Seek out or create a distraction-free study environment]"
[~,pQ20] = ttest(fullsetfil.BOQ_Q20,fullsetfil.EOQ_Q20)

% Q21
% "Rate the frequency which which you use the following learning techniques.
% [Study or work in a group]"
[~,pQ21] = ttest(fullsetfil.BOQ_Q21,fullsetfil.EOQ_Q21)

% Q22
% "Rate the frequency which which you use the following learning techniques.
% [Go to tutoring and/or office hours for help]"
[~,pQ22] = ttest(fullsetfil.BOQ_Q22,fullsetfil.EOQ_Q22)

% Checking frequency of use for those values that are found significant
% Q1
meandiffQ1 = mean(fullsetfil.EOQ_Q1) - mean(fullsetfil.BOQ_Q1)
% Q2
meandiffQ2 = mean(fullsetfil.EOQ_Q2) - mean(fullsetfil.BOQ_Q2)
% Q5
meandiffQ5 = mean(fullsetfil.EOQ_Q5) - mean(fullsetfil.BOQ_Q5)
% Q6
meandiffQ6 = mean(fullsetfil.EOQ_Q6) - mean(fullsetfil.BOQ_Q6)
% Q10
meandiffQ10 = mean(fullsetfil.EOQ_Q10) - mean(fullsetfil.BOQ_Q10)
% Q11
meandiffQ11 = mean(fullsetfil.EOQ_Q11) - mean(fullsetfil.BOQ_Q11)
% Q12
meandiffQ12 = mean(fullsetfil.EOQ_Q12) - mean(fullsetfil.BOQ_Q12)
% Q14
meandiffQ14 = mean(fullsetfil.EOQ_Q14) - mean(fullsetfil.BOQ_Q14)
% Q17
meandiffQ17 = mean(fullsetfil.EOQ_Q17) - mean(fullsetfil.BOQ_Q17)
% Q21
meandiffQ21 = mean(fullsetfil.EOQ_Q21) - mean(fullsetfil.BOQ_Q21)

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL\ttest')