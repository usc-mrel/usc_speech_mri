ccc

load('statistics.mat')

f = figure;
histogram(nw./(duration/60), [40:10:240]);
ylabel 'Frequency'
xlabel 'Words Per Minute'

set(gca, 'FontSize', 20)

hgexport(f, 'histogram.eps')