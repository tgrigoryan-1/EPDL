% Code for MAE131A Spring 25 Performance Scatter Final Exam / Composite Participation Indicator
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Setting up data, where p_data is participation data and g_data is grades data
p_data = readtable('MegaDataFile - MAE 131A Active Learning Participation.csv');
g_data = readtable('MegaDataFile - MAE131A A00 Grades.csv');
p_data = p_data(:,{'SISUserID','CompositeParticipationIndicator_ZScoreAvg_'});
g_data = g_data(:,{'SISUserID','FinalExamRawScore_924780_'});

% Joining the two data sets with the PID's as a key, using innerjoin to drop anyone that is not on both lists
data = innerjoin(p_data,g_data,'Keys','SISUserID');
indicator = data.CompositeParticipationIndicator_ZScoreAvg_;
exam_score = data.FinalExamRawScore_924780_;

% Scatter Plot
figure(1), scatter(indicator,exam_score,50,'filled')
xlabel('Composite Participation Indicator')
ylabel('Final Exam Score')
ylim([5 100])
title('MAE131A: Composite Participation Indicator vs. Final Exam Performance')

% Line of best fit
hold on;
% Fitting polynomial of degree 1 to data
coeff = polyfit(indicator, exam_score, 1);
% Creating value for indicator to plot the line onto
xfit = linspace(min(indicator), max(indicator), 100);
% Evaluating the line at the new x values
yfit = polyval(coeff, xfit);
% Plot the line
plot(xfit, yfit, 'r-', 'LineWidth', 1.5);
% Legend showing the coefficients in the y = mx + b equation used to fit
legend('Student Data', sprintf('Linear Fit: y = %.2fx + %.2f', coeff(1), coeff(2)));
hold off;

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL\scatter')