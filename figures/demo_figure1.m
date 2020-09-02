
%% Clean state
clear all; close all; clc;

%% Generate statistics
data_dir = '../data/';
output_dir = './figures/';
mkdir(output_dir);

all_file = dir(fullfile(data_dir, '*/recon/*.h5'));
N = size(all_file, 1);
j = 1;

frame_rate = 1000/6.004/2; 
for i = 1:N
    stimuli = all_file(i).name(8:11);

    switch stimuli
        case {'sc05', 'sc16'}
            nw(j) = 58;
        case {'sc6', 'sc17'}
            nw(j) = 98;
        case {'sc07', 'sc18'}
            nw(j) = 70;
        case {'sc08', 'sc19'}
            nw(j) = 60;
        case {'sc09', 'sc20'}
            nw(j) = 44;
        case {'sc10', 'sc21'}
            nw(j) = 76;
        otherwise
            continue
    end
    
    full_dir = fullfile(all_file(i).folder, all_file(i).name);
    info = h5info(full_dir, '/recon');
    
    duration(j) = info.Dataspace.Size(3) / frame_rate;
    j = j+1;
end

save('statistics.mat', 'nw', 'duration');

%% Display Figure 1

f = figure;
histogram(nw./(duration/60), [40:10:240]);
ylabel 'Frequency'
xlabel 'Words Per Minute'
set(gca, 'FontSize', 20);

% save figure
hgexport(f, fullfile(output_dir, 'figure1.eps'));
