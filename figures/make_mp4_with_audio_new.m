clear; clc; close all;

all_recon_file = dir('./dataset/*/*/2drt/recon/*.h5');


N = length(all_recon_file);
Nfail = 0;
fail_names = cell(1);
for i = 1:N
    
    h5_name = fullfile(all_recon_file(i).folder, all_recon_file(i).name);
    
    wav_name = dir([all_recon_file(i).folder(1:end-6), 'wav/', all_recon_file(i).name(1:20), '*']);
    
    if isempty(wav_name)
        wav_name = dir([all_recon_file(i).folder(1:end-6), 'wav/', all_recon_file(i).name(1:19), '*']);
    end
    
    if isempty(wav_name)
        fprintf(['No audio file for ', all_recon_file(i).name(1:20), '\n'])
        Nfail = Nfail + 1;
        fail_names{Nfail} = all_recon_file(i).name(1:20);
        continue
    else
        wav_name = fullfile(wav_name.folder, wav_name.name);
        [Audio, FS] = audioread(wav_name);
        
        noa = length(Audio);
        
        Image = h5read(h5_name, '/recon');
        Image = Image./max(Image(:)) * 2;
        nof = size(Image, 3);
        
        video_folder = [all_recon_file(i).folder(1:end-6), 'mp4_with_audio/'];
        
        if ~isfolder(video_folder)
            mkdir(video_folder)
        end
        
        video_name = [video_folder, all_recon_file(i).name(1:20), '.avi'];
        
        v = vision.VideoFileWriter(video_name, 'FileFormat', 'avi');
        v.FrameRate = 1000/(2*6.004);
        
        for ii = 1:nof
            v(Image(:,:,ii));
        end
        
        release(v)
        
        attach_audio_command = sprintf('ffmpeg -y -i %s -i %s -c:a copy %s_with_audio.avi', video_name, wav_name, video_name(1:end-4));
        system(attach_audio_command)
        
        convert_command = sprintf('ffmpeg -y -i %s_with_audio.avi %s.mp4', video_name(1:end-4), video_name(1:end-4));
        system(convert_command)
    end
    
    
end
Nfail
