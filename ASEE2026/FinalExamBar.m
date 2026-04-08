clear all, close all, clc
% Data for Final Exam Performance
mean_scores = [70.57, 63.58];
std_devs = [15.22, 20.76];

figure('Name', 'Final Exam Performance', 'Color', 'w', 'Position', [100, 100, 600, 500]);
hold on; % Turn hold on so we can plot multiple bars

% Define exact x-positions
x_pos1 = 1; % Position of the first bar
x_pos2 = 2; % Position of the second bar
absolute_width = 0.6; % The exact width of the bars

% Plot the first bar (High Participation)
b1 = bar(x_pos1, mean_scores(1), absolute_width);
b1.FaceColor = [0.7, 0.7, 0.7];
b1.EdgeColor = 'k';
b1.LineWidth = 1;

% Plot the second bar (Low Participation)
b2 = bar(x_pos2, mean_scores(2), absolute_width);
b2.FaceColor = [0.7, 0.7, 0.7];
b2.EdgeColor = 'k';
b2.LineWidth = 1;

% Add text labels inside the bars
text(x_pos1, 35, sprintf('%.2f%%', mean_scores(1)), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
    'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');

text(x_pos2, 35, sprintf('%.2f%%', mean_scores(2)), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
    'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');

hold off;

% Formatting
ax = gca;
ax.XColor = 'k';
ax.TickDir = 'out';

set(gca, 'XTick', [x_pos1, x_pos2], ...
    'XTickLabel', {'High (\geq3 Assignments)', 'Low (<3 Assignments)'}, ...
    'FontSize', 10, 'LineWidth', 1, 'FontWeight','bold');

% Now you can change xlim to add exactly as much empty space on the sides as you want
xlim([0, 3]); 
ylim([0, 100]);

ylabel('Mean Exam Score', 'FontSize', 12, 'FontWeight', 'bold');
title('Final Exam Performance', 'FontSize', 14);

b1.ShowBaseLine = 'off';
b2.ShowBaseLine = 'off';