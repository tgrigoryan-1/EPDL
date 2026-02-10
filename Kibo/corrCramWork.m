% Correlation Analysis Between MAE 131A Cramming and Hours Worked Per Week
close all, clear
% Naviagte to folder with data
cd('C:\Users\tigrr\Downloads')

% Set up the data as a table
c_data = readtable("Scores - Standardized.csv");
w_data = readtable("Scores - Hours.csv");
c_data = c_data(:,{'SISUserID','CrammingZScore'})
w_data = w_data(:,{'PID','HowManyHoursPerWeekDoYouWorkForPayThisQuarter_'})


% Historgram
% Define bin edges (the worked hours)
binEdges = [0, 5, 10, 15, 20, 25, 30, 35, 40];



% Get Z score for Hours worked
workHoursZScore = zscore(w_data.HowManyHoursPerWeekDoYouWorkForPayThisQuarter_)

% Add to table
w_data.workHoursZScore = workHoursZScore


% Join the two data sets together
fullset = innerjoin(c_data,w_data,'LeftKeys','SISUserID','RightKeys','PID')

% Find # of students that crammed
workHours = fullset.workHoursZScore
cram = fullset.CrammingZScore
numcram = sum(cram > 0);
numstud = height(fullset);
perccram = numcram/numstud

% Create histogram for hours worked
figure
histogram(fullset.HowManyHoursPerWeekDoYouWorkForPayThisQuarter_, binEdges, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'k')

% Labels and formatting
xlabel('Hours Worked per Week', 'FontSize', 12, 'FontWeight', 'bold')
ylabel('Number of Students', 'FontSize', 12, 'FontWeight', 'bold')
title('Distribution of Student Work Hours, n = 123', 'FontSize', 14, 'FontWeight', 'bold')

% Set x-axis to show all bin labels
xticks(0:5:40)
xlim([0 40])

% Pearson Correlation
% Data in Z-Score, normalizes distribution making Pearson appropriate as it reduces impact of outliers and skewness
% Trying to find linear relationship, as work hours increase does cramming?
[r_pearson, p_pearson] = corr(workHours, cram, 'Type', 'Pearson');

fprintf('Pearson Correlation: r = %.3f, p = %.4f\n', r_pearson, p_pearson);

%% Spearman Correlation (as robustness check)
[rho_spearman, p_spearman] = corr(workHours, cram, 'Type', 'Spearman');

fprintf('Spearman Correlation: rho = %.3f, p = %.4f\n', rho_spearman, p_spearman);

%% Visualize the relationship
figure
scatter(workHours, cram, 'filled', 'MarkerFaceAlpha', 0.6)
xlabel('Work Hours (Z-score)')
ylabel('Cramming (Z-score)')
title('Relationship Between Work Hours and Cramming')
lsline  % Add linear fit line
grid on