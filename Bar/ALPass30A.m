% Code for active learning participation in 30A (B00)
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')
close all, clear, clc

% First pull the Active Learning Participation data
% p_data is the data of participants, 1 representing the first sheet and 2 representing the second sheet
p_data1 = readtable('MegaDataFile - MAE30A B00 Active Learning Participation');
p_data1 = p_data1(:,{'SISUserID','AllActiveLearning'});
p_data2 = readtable('MegaDataFile - MAE30A B00 Active Learning Participation 2');
p_data2 = p_data2(:,{'SISUserID','AllActiveLearning'});

% Sort both by SISUserID first to align rows, then compare to see if the data is the same
p1_sorted = sortrows(p_data1, 'SISUserID');
p2_sorted = sortrows(p_data2, 'SISUserID');

is_identical = isequal(p1_sorted, p2_sorted);

% --Pass/No Pass Bar Chart --

% Returned a 1 so the data is identical so we can continue to make a bar graph
% We need to set an arbitrary value for a "pass" for the active learning
% In order to do this we want to see a median score
med_val = median(p_data1.AllActiveLearning);

% Classify students into groups
pass_count = sum(p_data1.AllActiveLearning > med_val);
nopass_count = sum(p_data1.AllActiveLearning <= med_val);
pass_per = (pass_count/length(p_data1.AllActiveLearning))*100;
nopass_per = (nopass_count/length(p_data1.AllActiveLearning))*100;

% Plot
figure (1);
labels = ["No Pass" "Pass"];
count = [nopass_per pass_per];
b = bar(labels,count);

%% Labelling
title('Active Learning Participation: Pass vs No Pass', 'FontSize', 14)
xlabel('Participation Status', 'FontSize', 12)
ylabel('Percentage of Students (%)', 'FontSize', 12)
xtips = b.XEndPoints; % Gets the center X coordinate of each bar
ytips = b.YEndPoints; % Gets the top Y coordinate of each bar

% Format the text to 2 decimal place and append a '%' sign
str_labels = string(round(count, 2)) + "%"; 

% Place the text on the chart
text(xtips, ytips, str_labels, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', 12, 'FontWeight', 'bold')
