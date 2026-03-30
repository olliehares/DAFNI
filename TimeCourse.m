%% fMRI Time-Series Analysis and Visualization
% This script extracts, processes, and visualizes mean BOLD time-series data
% from functionally defined regions of interest (FFA and LOC).

% 1. Setup and Initialization Parameters
data_files = {'swrsub-01-fmri01.nii', 'swrsub-01-fmri02.nii'}; 
TR = 1.5; % Repetition time in seconds
n_vols = 160; % Total number of volumes per run
roi_radius = 5; % Radius of the spherical ROI in millimeters

% Peak MNI coordinates derived from categorical contrasts
ffa_mni = [24, -88, -13]; % Right Occipital Fusiform Gyrus (FFA)
loc_mni = [-30, -82, 38]; % Left Middle Occipital Gyrus (LOC)

% 2. Experimental Design Onset Times
% Stimulus onset times extracted from the block-design paradigm
face_onsets = [12, 60, 108, 156, 204]; 
object_onsets = [36, 84, 132, 180, 228]; 
duration = 12; % Block duration in seconds

% 3. Data Extraction and Preprocessing
all_ffa_psc = zeros(n_vols, length(data_files));
all_loc_psc = zeros(n_vols, length(data_files));

for r = 1:length(data_files)
    V = spm_vol(data_files{r});
    
    % Extract raw BOLD signal from the defined spherical ROIs using SPM
    ffa_raw = spm_summarise(V, struct('def', 'sphere', 'spec', roi_radius, 'xyz', ffa_mni'), @mean);
    loc_raw = spm_summarise(V, struct('def', 'sphere', 'spec', roi_radius, 'xyz', loc_mni'), @mean);
    
    % Convert raw signal to Percent Signal Change (PSC) relative to the mean
    all_ffa_psc(:,r) = (ffa_raw - mean(ffa_raw)) / mean(ffa_raw) * 100;
    all_loc_psc(:,r) = (loc_raw - mean(loc_raw)) / mean(loc_raw) * 100;
end

% Average the PSC data across functional runs to improve the signal-to-noise ratio
mean_ffa = mean(all_ffa_psc, 2);
mean_loc = mean(all_loc_psc, 2);
time_s = (0:n_vols-1) * TR; % Construct the time vector

% 4. Data Visualization
figure('Color', 'w', 'Name', 'ROI Time-Course Analysis');
hold on;

% Calculate Y-axis limits dynamically based on the data range
y_lims = [min([mean_ffa; mean_loc]) - 0.5, max([mean_ffa; mean_loc]) + 0.5];
y_height = y_lims(2) - y_lims(1);

% Overlay Face stimulus blocks (shaded red)
for i = 1:length(face_onsets)
    rectangle('Position', [face_onsets(i), y_lims(1), duration, y_height], ...
    'FaceColor', [1 0.9 0.9], 'EdgeColor', 'none');
end

% Overlay Object stimulus blocks (shaded green)
for i = 1:length(object_onsets)
    rectangle('Position', [object_onsets(i), y_lims(1), duration, y_height], ...
    'FaceColor', [0.9 1 0.9], 'EdgeColor', 'none');