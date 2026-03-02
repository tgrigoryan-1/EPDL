% Code for active learning participation in 131A (A00) SP25
% THIS CODE USES QUALITY TO INDICATE A PASS OR NOT
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')
close all, clear, clc

% First pull the Active Learning Participation data
% p_data is the data of participants
p_data = readtable('MegaDataFile - MAE 131A Active Learning Participation');
p_data = p_data(:,{'SISUserID','ActiveRecallScore_Max190_', 'ActiveRecallAmount_Max19_', 'ConceptMapScore_Max120_', 'ConceptMapAmount_Max4_'})

% Define Thresholds and Calculate Scores
total_max_points = 190 + 120; % Max possible points across both categories
pass_threshold = 0.20; % 20% required to pass (adjust as needed) arbitrary??

% Calculate total points earned by each student
total_scores = p_data.ActiveRecallScore_Max190_ + p_data.ConceptMapScore_Max120_;

% Create a logical array: 1 for Pass, 0 for No Pass
pass_status = (total_scores / total_max_points) >= pass_threshold;

% Calculate Percentages for the Plot
total_students = height(p_data);
pass_count = sum(pass_status == 1);
nopass_count = sum(pass_status == 0);

pass_per = (pass_count / total_students) * 100;
nopass_per = (nopass_count / total_students) * 100;

% Plot
figure(1);
labels = ["No Pass", "Pass"];
count = [nopass_per, pass_per];

% Assign the bar chart to 'b'
b = bar(labels, count);

% Add title and axis labels
title('Combined Active Learning: Pass vs No Pass', 'FontSize', 14)
xlabel('Participation Status', 'FontSize', 12)
ylabel('Percentage of Students (%)', 'FontSize', 12)

% Add values on top of the bars
xtips = b.XEndPoints;
ytips = b.YEndPoints;
str_labels = string(round(count, 1)) + "%"; 

text(xtips, ytips, str_labels, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', 12, 'FontWeight', 'bold')

% Extend Y-axis slightly so the labels have breathing room at the top
ylim([0, max(count) * 1.15])
