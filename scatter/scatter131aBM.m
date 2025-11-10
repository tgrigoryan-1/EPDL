% Code for MAE131A Spring 25 Performance Scatter Midterm Exam / Participation Before Midterm
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Setting up data, where p_data is participation data and g_data is grades data
p_data = readtable('MegaDataFile - MAE 131A Active Learning Participation.csv');
g_data = readtable('MegaDataFile - MAE131A A00 Grades.csv');
p_data = p_data(:,{'SISUserID','AmountBeforeMidterm'});
g_data = g_data(:,{'SISUserID','MidtermExam_971071_'});

% Joining the two data sets with the PID's as a key, using innerjoin to drop anyone that is not on both lists
data = innerjoin(p_data,g_data,'Keys','SISUserID');
participation = data.AmountBeforeMidterm;
exam_score = data.MidtermExam_971071_;

% Scatter Plot
figure(1), scatter(participation,exam_score,50,'filled')
xlabel('Participation Count Before Midterm')
ylabel('Midterm Exam Score')
title('MAE131A: Participation vs. Midterm Exam Performance')

% Line of best fit
hold on;
% Fitting polynomial of degree 1 to data
coeff = polyfit(participation, exam_score, 1);
% Creating value for participation to plot the line onto
xfit = linspace(min(participation), max(participation), 100);
% Evaluating the line at the new x values
yfit = polyval(coeff, xfit);
% Plot the line
plot(xfit, yfit, 'r-', 'LineWidth', 1.5);
% Legend showing the coefficients in the y = mx + b equation used to fit
legend('Student Data', sprintf('Linear Fit: y = %.2fx + %.2f', coeff(1), coeff(2)));
hold off;

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL\scatter')