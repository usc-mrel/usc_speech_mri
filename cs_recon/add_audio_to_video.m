clear;
clc;

% Configuration
% set up following variables.
dataroot = pwd;  % path to subject directory

% Directory parameters
% video_dir = 'avi';  % directory under dataroot where the video files are stored
video_dir = 'avi';  % directory under dataroot where the video files are stored
video_ext = 'avi';  % filename extension for the video files
audio_dir = 'wav';  % directory under dataroot where the denoised audio will be stored
video_plus_audio_dir = 'avi_withaudio';  % directory under dataroot where the video with audio added will be stored

% ================ Don't touch code below ====================

% cd to 'dataroot' directory
system(['cd ', dataroot]);

% Get video list
videofiles = dir([dataroot, '/', video_dir, '/*.', video_ext]);

% Create output directories for storing video with audio added
%mkdir ([dataroot, '/', video_plus_audio_dir]);
 system(['mkdir ', dataroot, '/', video_plus_audio_dir]);

% Begin noise cancellation and merging audio with video
for file_count = 1 : length(videofiles)
    [~, videofilename] = fileparts(videofiles(file_count).name);

	% Merge denoised audio with video
    if exist([dataroot, '/', video_plus_audio_dir, '/', videofilename(1:20) '_withaudio.avi'])
        display(['Already created avi file ', dataroot, '/', video_plus_audio_dir, '/', videofilename(1:20), '_withaudio.avi. Skipping']);
    else
        system(['ffmpeg -i ', dataroot, '/', video_dir, '/', videofilename(1:20), '.', video_ext, ' -i ', dataroot, '/', audio_dir, '/', videofilename(1:20), '.wav -c:a copy ', dataroot, '/', video_plus_audio_dir, '/', videofilename(1:20), '_withaudio.', video_ext]);
        %system(['mencoder -audiofile ', dataroot, '/wav/', videofilename, '.wav -oac copy -ovc copy ', dataroot, '/avi/', videofilename, '.avi -o ', dataroot, '/avi_withaudio/', videofilename, '_withaudio.avi']);
    end
end

% Done
disp('Done');
