function pupil_area_analysis(aninum)

%% process trials
frameRate=7.5;
prestimFrames=20;
totalFrames=size(cell_activity,4);
fixed_dist=size(speed_fixed_pos,2);
blo1=1:10; blo2=11:170; blo3=171:210;
% savepath = ['C:\Users\Neuropixel\Documents\SEanalysis\' ani 'behavplots'];
colorsmat=[96, 211, 148; 242, 143, 59; 30, 112, 206;228, 87, 46]./255; % 238, 96, 85 . [[155, 204, 85]./255; [228, 87, 46]./255; [179, 201, 174]./255; [239, 149, 137]./255]; green, orange, blue, red
% get ntrial
starttrial_mask = [false; diff(DAQdata2.position_tunnel) < -.4];
starttrial_mask_clean = [diff(starttrial_mask) == -1; false];
ntrial = sum(starttrial_mask_clean) - 1;
starttrial_index = find(starttrial_mask_clean==1);

% get trigger points
startstim_mask = [false; diff(DAQdata2.stim_id) > .1];
startstim_indices = find(diff(startstim_mask) == 1);
position_diode = DAQdata2(startstim_indices,:).position_tunnel;

% onset of A1/B1 gratings
gratings_on = [2, 3.5];
gratings_off = [3.5, 4.4];
n_gratings = 2;
gratings_indices = cell(1, n_gratings);
% decide window to plot in frames
win.idx = -19:40;

for ii = 1:n_gratings
    mask = (position_diode < gratings_off(ii)) & (position_diode > gratings_on(ii));
    gratings_trigger = startstim_indices(mask);
    gratings_indices{ii} = gratings_trigger + win.idx;
end

% remove A1/B1/A2/B2 that are before first A1 (first positive frame number)
first_a1_idx = find(gratings_indices{1}(:, 1) > 0, 1);
first_a1 = gratings_indices{1}(first_a1_idx, 1);
for ii = 1:n_gratings
    if gratings_indices{ii}(1, 1) < first_a1
        gratings_indices{ii} = gratings_indices{ii}(2:end, :);
    end
end

% remove A1/B1/A2 that are after last B2
last_b2 = gratings_indices{end}(end, 1);
for ii = 1:n_gratings-1
    if gratings_indices{ii}(end, 1) > last_b2
        gratings_indices{ii} = gratings_indices{ii}(1:end-1, :);
    end
end

% x=DAQdata2.pupil_longaxis;
% x=lowpass(fillmissing(x,'linear'),10,7.5);
% x=highpass(x,0.1,7.5); x=zscore(x);
% 
% area=lowpass(fillmissing(DAQdata2.pupil_area,'linear'),10,7.5);
% area=highpass(DAQdata2.pupil_area,0.1,7.5); area=zscore(DAQdata2.pupil_area);
