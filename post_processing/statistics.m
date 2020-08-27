ccc

all_file = dir('/server/sdata_new/Speech/dataset/*/recon/*.h5');
N = size(all_file, 1);
j = 1;

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
    
    duration(j) = info.Dataspace.Size(3) / (1000/6.004/2);
    j = j+1;
end

save('statistics.mat', 'nw', 'duration');