function [] = deal_with_sac()

acceleration_thresh = 2; %previously 1
velocity_thresh = 25;
lag_time = 20;


files = dir;

for i = 3:length(files)
    d = readcxdata(files(i).name); %from Maestro distribution
    %{
    if strcmp(d.trialname(1),'p') & length(d.data(3,:)) < d.trialInfo.segStart(4)
        continue
    elseif strcmp(d.trialname(1), 'g') & length(d.data(3,:)) < d.trialInfo.segStart(5)
        continue
    end
    %
    if strcmp(d.trialname(1), 'g')
        motion_start = d.trialInfo.segStart(4);
    elseif strcmp(d.trialname(1), 'p') | strcmp(d.trialname(1), 's')
        motion_start = d.trialInfo.segStart(3);
    else
        %}
    if length(d.trialInfo.segStart)==1
        motion_start = 500;
    elseif ~isempty(d.tagSections)
        motion_start = double(d.tagSections(1).tStart);
    else
        motion_start = d.trialInfo.segStart(2); %500 for calibration
    end

    temp_h_vel = d.data(3,:)./10.8826;
    temp_v_vel = d.data(4,:)./10.8826;
    if motion_start-300 < 1
        prior = motion_start-1;
    else
        prior = 300;
    end
    avg=mean(temp_h_vel(1,motion_start-prior:motion_start));
    temp_h_vel = temp_h_vel-avg;
    avg=mean(temp_v_vel(1,motion_start-prior:motion_start));
    temp_v_vel = temp_v_vel-avg;
    edit_struct.mark1 = [];
    edit_struct.mark2 = [];
    edit_struct.cut = [];
    edit_struct.marks = [];
    edit_struct.tags = [];
    edit_struct.discard = [];
    edit_struct.sortedSpikes = d.sortedSpikes;
    raw_speed = sqrt(temp_h_vel.^2 + temp_v_vel.^2);
    [sac_start, sac_end] = mark_saccades(raw_speed, acceleration_thresh, velocity_thresh, lag_time, motion_start);
    edit_struct.mark1 = sac_start;
    edit_struct.mark2 = sac_end;

    res = editcxdata( files(i).name, edit_struct);


end
end
