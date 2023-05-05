function [area,centre]=pupil_DLCextract(dpath)
    load(fullfile(dpath,'\CAM0.mat')); % load camera settings
    load(fullfile(dpath,'\DAQdata.mat')); % load behavior data
    downsamp(:,1)=knnsearch(DAQdata2.system_time,CAM0.ms); % uc1=unique(downsamp(:,1));
    fname=dir('*.csv'); 

    PupilFileName= fullfile(dpath,fname.name);% PupilFileName='Z:\mrsic_flogel\public\projects\SaEl_20220201_VIP\2pdata\vipsilencing\se010\E\labview_data\10EDLC_resnet50_pupiltrackingNov30shuffle1_500000.csv';
    PupilTable=csvread(PupilFileName,3,1);

    ConfidenceThreshold=0.95;
    RemoveArray=(double(PupilTable(:,3:3:end)>ConfidenceThreshold))./(PupilTable(:,3:3:end)>ConfidenceThreshold);
    RemoveArray(1==[zeros(1,size(PupilTable,2)/3);(abs(diff(PupilTable(:,2:3:end)))>20)])=NaN;
    for col=1:size(RemoveArray,2)
       RemoveArray(:,col)=MeanFilter(RemoveArray(:,col),3,0);
       RemoveTable(:,col)=accumarray( downsamp(:,1), RemoveArray(:,col), [], @nanmean ) ;
    end
    for col=1:size(PupilTable,2)
        DownPupilTable(:,col)=accumarray( downsamp(:,1), PupilTable(:,col), [], @nanmean ) ;
    end
    area=nan(length(RemoveTable),1);
    centre=nan(length(RemoveTable),2);
    phi=nan(length(RemoveTable),1);
    axes=nan(length(RemoveTable),2);
    long_axis=nan(length(RemoveTable),1);

    for fr=1:length(RemoveTable)
        x=DownPupilTable(fr,1:3:end).*RemoveTable(fr,:);
        y=DownPupilTable(fr,2:3:end).*RemoveTable(fr,:);
        x_med=nanmedian(DownPupilTable(fr,1:3:end).*RemoveTable(fr,:));
        y_med=nanmedian(DownPupilTable(fr,1:3:end).*RemoveTable(fr,:));
        for j=1:size(RemoveTable,2)
           if(abs(x(j)-x_med)>2*nanmedian(abs(x-x_med)))
               x(j)=NaN;
               y(j)=NaN;
           end
          if(abs(y(j)-y_med)>2*nanmedian(abs(y-y_med)))
               x(j)=NaN;
               y(j)=NaN;
          end
        end
        x=x(~isnan(x));
        y=y(~isnan(y));
        if length(x)>=5
            ellipse_t = fit_ellipse(x,y);
            if(isempty(ellipse_t))
                area(fr)=NaN; phi(fr)=NaN; axes(fr,:)=[NaN,NaN];
                centre(fr,:)=[NaN,NaN]; long_axis(fr)=NaN;
            elseif isempty(pi*ellipse_t.a*ellipse_t.b)
                area(fr)=NaN;phi(fr)=NaN;long_axis(fr)=NaN;
                centre(fr,:)=[NaN,NaN]; axes(fr,:)=[NaN,NaN];
            else 
                area(fr)=pi*ellipse_t.a*ellipse_t.b; phi(fr)=ellipse_t.phi;
                long_axis(fr)=ellipse_t.long_axis;
                centre(fr,:)=[ellipse_t.X0_in,ellipse_t.Y0_in]; axes(fr,:)=[ellipse_t.a,ellipse_t.b];
            end
        else
            area(fr)=NaN; phi(fr)=NaN; long_axis(fr)=NaN;
            centre(fr,:)=[NaN,NaN];axes(fr,:)=[NaN,NaN];
        end
    end
%     int_long_axis=interp1(find(isnan(long_axis)),long_axis); % linearly interp missing vals
%     int_centre=interp1(find(isnan(centre)),centre); % linearly interp missing vals
%     int_area=interp1(find(isnan(area)),area); % linearly interp missing vals

    %DAQdata2.pupil_longaxis= mean(reshape(a(1:51900),round(size(a(1:51900),1)/60), 60,[]),2) % downsample and bin avg
    DAQdata2.pupil_area = area; DAQdata2.pupil_centre = centre;
    DAQdata2.pupil_longaxis = long_axis;
    save(fullfile(dpath,'DAQdata.mat'),'DAQdata2'); % update daq data and save
end